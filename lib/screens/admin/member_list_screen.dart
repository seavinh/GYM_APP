import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/member_provider.dart';
import 'member_form_screen.dart';

class MemberListScreen extends StatefulWidget {
  const MemberListScreen({super.key});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  void _loadMembers() {
    context.read<MemberProvider>().loadMembers(
      context.read<AuthProvider>(),
      search: _searchQuery.isEmpty ? null : _searchQuery,
      refresh: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadMembers,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, email, phone...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                          _loadMembers();
                        },
                      )
                    : null,
              ),
              onSubmitted: (v) {
                setState(() => _searchQuery = v);
                _loadMembers();
              },
            ),
          ),
          Expanded(
            child: Consumer<MemberProvider>(
              builder: (context, memberProvider, _) {
                if (memberProvider.isLoading && memberProvider.members.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.accentTeal));
                }

                if (memberProvider.members.isEmpty) {
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
                          child: const Icon(Icons.people_outline_rounded, size: 48, color: AppTheme.textMuted),
                        ),
                        const SizedBox(height: 16),
                        const Text('No members found', style: TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  itemCount: memberProvider.members.length,
                  itemBuilder: (context, index) {
                    final member = memberProvider.members[index];
                    final roleColor = member.role == 'admin'
                        ? AppTheme.accentPink
                        : member.role == 'receptionist'
                            ? AppTheme.accentYellow
                            : AppTheme.accentTeal;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: AppTheme.glassCard,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(14),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: roleColor.withAlpha(15),
                          child: Text(
                            member.fullName.substring(0, 1).toUpperCase(),
                            style: TextStyle(color: roleColor, fontWeight: FontWeight.w700, fontSize: 18),
                          ),
                        ),
                        title: Text(
                          member.fullName,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(Icons.email_outlined, size: 12, color: AppTheme.textMuted),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  member.email,
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: PopupMenuButton(
                          icon: Icon(Icons.more_vert_rounded, color: AppTheme.textMuted, size: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppTheme.error))),
                          ],
                          onSelected: (value) async {
                            if (value == 'edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MemberFormScreen(member: member),
                                ),
                              );
                            } else if (value == 'delete') {
                              _confirmDelete(member);
                            }
                          },
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const MemberFormScreen()));
        },
        child: const Icon(Icons.add_rounded, size: 26),
      ),
    );
  }

  void _confirmDelete(dynamic member) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Member'),
        content: Text('Remove ${member.fullName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<MemberProvider>().deleteMember(
                context.read<AuthProvider>(),
                member.memberId,
              );
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}
