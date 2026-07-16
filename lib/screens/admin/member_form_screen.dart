import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../models/member.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/member_controller.dart';

class MemberFormScreen extends StatefulWidget {
  final Member? member;

  const MemberFormScreen({super.key, this.member});

  @override
  State<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends State<MemberFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  String _gender = AppConstants.genderMale;
  DateTime _dob = DateTime(2000, 1, 1);
  DateTime _joinDate = DateTime.now();
  bool _createUserAccount = false;
  String _role = AppConstants.roleMember;
  late TextEditingController _usernameController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    final m = widget.member;
    _nameController = TextEditingController(text: m?.fullName ?? '');
    _phoneController = TextEditingController(text: m?.phone ?? '');
    _emailController = TextEditingController(text: m?.email ?? '');
    _addressController = TextEditingController(text: m?.address ?? '');
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    if (m != null) {
      _gender = m.gender;
      _dob = m.dob;
      _joinDate = m.joinDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isDob) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isDob ? _dob : _joinDate,
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.accentTeal,
              surface: AppTheme.cardDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isDob) {
          _dob = picked;
        } else {
          _joinDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final Map<String, dynamic> data = {
      'full_name': _nameController.text.trim(),
      'gender': _gender,
      'dob': _dob.toIso8601String().substring(0, 10),
      'phone': _phoneController.text.trim(),
      'email': _emailController.text.trim(),
      'address': _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      'join_date': _joinDate.toIso8601String().substring(0, 10),
    };

    if (_createUserAccount) {
      data['create_user_account'] = true;
      data['username'] = _usernameController.text.trim();
      data['password'] = _passwordController.text;
      data['role'] = _role;
    }

    if (widget.member != null && widget.member!.userId != null) {
      data['role'] = _role;
    }

    final auth = Get.find<AuthController>();
    final memberProvider = Get.find<MemberController>();

    bool success;
    if (widget.member != null) {
      success = await memberProvider.updateMember(auth, widget.member!.memberId, data);
    } else {
      final result = await memberProvider.createMember(auth, data);
      success = result != null;
    }

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.member != null ? 'Member updated' : 'Member created'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.member != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Member' : 'Add Member'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.glassCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.accentTeal.withAlpha(20), AppTheme.accentTeal.withAlpha(5)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isEditing ? Icons.edit_rounded : Icons.person_add_rounded,
                          color: AppTheme.accentTeal,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isEditing ? 'Member Details' : 'New Member',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline_rounded)),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _gender,
                    decoration: const InputDecoration(labelText: 'Gender', prefixIcon: Icon(Icons.wc_outlined)),
                    items: const [
                      DropdownMenuItem(value: AppConstants.genderMale, child: Text('Male')),
                      DropdownMenuItem(value: AppConstants.genderFemale, child: Text('Female')),
                      DropdownMenuItem(value: AppConstants.genderOther, child: Text('Other')),
                    ],
                    onChanged: (v) => setState(() => _gender = v!),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Date of Birth'),
                    subtitle: Text(DateFormat('MMM d, yyyy').format(_dob)),
                    trailing: const Icon(Icons.calendar_today_rounded, color: AppTheme.accentTeal),
                    onTap: () => _selectDate(context, true),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Join Date'),
                    subtitle: Text(DateFormat('MMM d, yyyy').format(_joinDate)),
                    trailing: const Icon(Icons.calendar_today_rounded, color: AppTheme.accentTeal),
                    onTap: () => _selectDate(context, false),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone_outlined)),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Address (optional)', prefixIcon: Icon(Icons.home_outlined)),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            if (!isEditing) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.glassCard,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Create User Account'),
                      subtitle: const Text('Allow member to log in', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      value: _createUserAccount,
                      onChanged: (v) => setState(() => _createUserAccount = v),
                      activeThumbColor: AppTheme.accentTeal,
                    ),
                    if (_createUserAccount) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(labelText: 'Username', prefixIcon: Icon(Icons.alternate_email_rounded)),
                        validator: _createUserAccount ? (v) => v == null || v.isEmpty ? 'Required' : null : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline_rounded)),
                        obscureText: true,
                        validator: _createUserAccount ? (v) => v == null || v.length < 6 ? 'Min 6 characters' : null : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _role,
                        decoration: const InputDecoration(labelText: 'Role', prefixIcon: Icon(Icons.badge_outlined)),
                        items: const [
                          DropdownMenuItem(value: AppConstants.roleMember, child: Text('Member')),
                          DropdownMenuItem(value: AppConstants.roleReceptionist, child: Text('Receptionist')),
                          DropdownMenuItem(value: AppConstants.roleAdmin, child: Text('Admin')),
                        ],
                        onChanged: (v) => setState(() => _role = v!),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            if (isEditing && widget.member?.userId != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: AppTheme.glassCard,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.badge_outlined, color: AppTheme.accentPurple, size: 20),
                        const SizedBox(width: 8),
                        const Text('User Account', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _role,
                      decoration: const InputDecoration(labelText: 'Role', prefixIcon: Icon(Icons.admin_panel_settings_outlined)),
                      items: const [
                        DropdownMenuItem(value: AppConstants.roleMember, child: Text('Member')),
                        DropdownMenuItem(value: AppConstants.roleReceptionist, child: Text('Receptionist')),
                        DropdownMenuItem(value: AppConstants.roleAdmin, child: Text('Admin')),
                      ],
                      onChanged: (v) => setState(() => _role = v!),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _save,
              child: Text(isEditing ? 'Update Member' : 'Create Member'),
            ),
          ],
        ),
      ),
    );
  }
}
