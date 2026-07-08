import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../models/payment.dart';
import '../../providers/auth_provider.dart';
import '../../providers/member_provider.dart';
import '../../providers/membership_provider.dart';
import '../../providers/payment_provider.dart';

class PaymentRecordScreen extends StatefulWidget {
  const PaymentRecordScreen({super.key});

  @override
  State<PaymentRecordScreen> createState() => _PaymentRecordScreenState();
}

class _PaymentRecordScreenState extends State<PaymentRecordScreen> {
  int? _selectedMemberId;
  int? _selectedMembershipId;
  final _amountController = TextEditingController();
  DateTime _paymentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final auth = context.read<AuthProvider>();
    context.read<MemberProvider>().loadMembers(auth, refresh: true);
    context.read<MembershipProvider>().loadMemberships(auth);
    context.read<PaymentProvider>().loadPayments(auth, refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Container(
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
                            colors: [AppTheme.accentYellow.withAlpha(20), AppTheme.accentYellow.withAlpha(5)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.receipt_long_rounded, color: AppTheme.accentYellow, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text('Record Payment', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 16),
                    Consumer<MemberProvider>(
                      builder: (context, memberProv, _) {
                        return DropdownButtonFormField<int>(
                          initialValue: _selectedMemberId,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Member', prefixIcon: Icon(Icons.person_outline_rounded)),
                        items: memberProv.members.map((m) => DropdownMenuItem(
                          value: m.memberId,
                          child: Text(m.fullName),
                        )).toList(),
                        onChanged: (v) => setState(() => _selectedMemberId = v),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                    Consumer<MembershipProvider>(
                      builder: (context, memProv, _) {
                        return DropdownButtonFormField<int>(
                          initialValue: _selectedMembershipId,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Membership Plan', prefixIcon: Icon(Icons.card_membership_rounded)),
                        items: memProv.memberships.map((m) => DropdownMenuItem(
                          value: m.membershipId,
                          child: Text('${m.membershipName} - \$${m.price.toStringAsFixed(0)}'),
                        )).toList(),
                        onChanged: (v) {
                          setState(() => _selectedMembershipId = v);
                          final plan = memProv.memberships.firstWhere((m) => m.membershipId == v, orElse: () => memProv.memberships.first);
                          _amountController.text = plan.price.toString();
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _amountController,
                    decoration: const InputDecoration(labelText: 'Amount (\$)', prefixIcon: Icon(Icons.attach_money_rounded)),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Payment Date'),
                    subtitle: Text(DateFormat('MMM d, yyyy').format(_paymentDate)),
                    trailing: const Icon(Icons.calendar_today_rounded, color: AppTheme.accentTeal),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _paymentDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setState(() => _paymentDate = picked);
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitPayment,
                      child: const Text('Record Payment'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Recent Payments', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Consumer<PaymentProvider>(
              builder: (context, paymentProvider, _) {
                if (paymentProvider.isLoading && paymentProvider.payments.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.accentTeal));
                }

                if (paymentProvider.payments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.textMuted.withAlpha(15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.receipt_long_outlined, size: 48, color: AppTheme.textMuted),
                        ),
                        const SizedBox(height: 16),
                        const Text('No payment records', style: TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: paymentProvider.payments.length,
                  itemBuilder: (context, index) {
                    final payment = paymentProvider.payments[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: AppTheme.glassCard,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(14),
                        leading: CircleAvatar(
                          radius: 22,
                          backgroundColor: AppTheme.accentYellow.withAlpha(15),
                          child: const Icon(Icons.payment_rounded, color: AppTheme.accentYellow, size: 20),
                        ),
                        title: Text(
                          payment.member?.fullName ?? 'Member #${payment.memberId}',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${payment.membership?.membershipName ?? 'Plan #${payment.membershipId}'}  •  ${DateFormat('MMM d, yyyy').format(payment.paymentDate)}',
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '\$${payment.amount.toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.accentYellow, fontSize: 16),
                            ),
                            PopupMenuButton(
                              icon: const Icon(Icons.more_vert_rounded, color: AppTheme.textMuted, size: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'receipt', child: Text('View Receipt')),
                                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                                const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppTheme.error))),
                              ],
                              onSelected: (value) {
                                if (value == 'receipt') _showReceipt(payment);
                                if (value == 'edit') _showEditSheet(payment);
                                if (value == 'delete') _confirmDelete(payment);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitPayment() async {
    if (_selectedMemberId == null || _selectedMembershipId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select member and plan'), backgroundColor: AppTheme.error),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid amount'), backgroundColor: AppTheme.error),
      );
      return;
    }

    final result = await context.read<PaymentProvider>().createPayment(
      context.read<AuthProvider>(),
      {
        'member_id': _selectedMemberId,
        'membership_id': _selectedMembershipId,
        'amount': amount,
        'payment_date': _paymentDate.toIso8601String().substring(0, 10),
      },
    );

    if (mounted) {
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment recorded'), backgroundColor: AppTheme.success),
        );
        setState(() {
          _selectedMemberId = null;
          _selectedMembershipId = null;
          _amountController.clear();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to record payment'), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  Future<void> _showReceipt(Payment payment) async {
    final receipt = await context.read<PaymentProvider>().getReceipt(
      context.read<AuthProvider>(),
      payment.paymentId,
    );

    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.receipt_rounded, color: AppTheme.accentYellow, size: 22),
              const SizedBox(width: 8),
              const Text('Receipt'),
            ],
          ),
          content: receipt != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _receiptRow('Receipt #', '${receipt['payment_id']}'),
                    _receiptRow('Member', receipt['member_name'] ?? '-'),
                    _receiptRow('Plan', receipt['membership'] ?? '-'),
                    _receiptRow('Amount', '\$${double.parse(receipt['amount'].toString()).toStringAsFixed(2)}'),
                    _receiptRow('Date', '${receipt['payment_date']}'),
                    _receiptRow('Expires', '${receipt['expiry_date']}'),
                  ],
                )
              : const Text('Failed to load receipt', style: TextStyle(color: AppTheme.error)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ],
        ),
      );
    }
  }

  Widget _receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        ],
      ),
    );
  }

  void _showEditSheet(Payment payment) {
    final amountController = TextEditingController(text: payment.amount.toString());
    DateTime paymentDate = payment.paymentDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textMuted.withAlpha(80),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Edit Payment', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount (\$)', prefixIcon: Icon(Icons.attach_money_rounded)),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 14),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Payment Date'),
                subtitle: Text(DateFormat('MMM d, yyyy').format(paymentDate)),
                trailing: const Icon(Icons.calendar_today_rounded, color: AppTheme.accentTeal),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: paymentDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setSheetState(() => paymentDate = picked);
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final amount = double.tryParse(amountController.text);
                    if (amount == null || amount <= 0) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Enter a valid amount'), backgroundColor: AppTheme.error),
                      );
                      return;
                    }

                    final success = await context.read<PaymentProvider>().updatePayment(
                      context.read<AuthProvider>(),
                      payment.paymentId,
                      {
                        'amount': amount,
                        'payment_date': paymentDate.toIso8601String().substring(0, 10),
                      },
                    );

                    if (ctx.mounted) Navigator.pop(ctx);

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? 'Payment updated' : 'Failed to update'),
                          backgroundColor: success ? AppTheme.success : AppTheme.error,
                        ),
                      );
                    }
                  },
                  child: const Text('Update'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(Payment payment) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Payment'),
        content: const Text('Remove this payment record? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<PaymentProvider>().deletePayment(
                context.read<AuthProvider>(),
                payment.paymentId,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Payment deleted' : 'Failed to delete'),
                    backgroundColor: success ? AppTheme.success : AppTheme.error,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}
