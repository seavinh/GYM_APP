import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/membership_controller.dart';

class PlanListScreen extends StatefulWidget {
  const PlanListScreen({super.key});

  @override
  State<PlanListScreen> createState() => _PlanListScreenState();
}

class _PlanListScreenState extends State<PlanListScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<MembershipController>().loadMemberships(Get.find<AuthController>());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Membership Plans')),
      body: GetBuilder<MembershipController>(
        builder: (provider) {
          if (provider.isLoading && provider.memberships.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.accentTeal));
          }

          if (provider.memberships.isEmpty) {
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
                    child: const Icon(Icons.card_membership_outlined, size: 48, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 16),
                  const Text('No plans configured', style: TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: provider.memberships.length,
            itemBuilder: (context, index) {
              final plan = provider.memberships[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: AppTheme.glassCard,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.accentTeal.withAlpha(20), AppTheme.accentTeal.withAlpha(5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.card_membership_rounded, color: AppTheme.accentTeal, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(plan.membershipName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(
                              '${plan.duration} month${plan.duration > 1 ? 's' : ''}',
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '\$${plan.price.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.accentYellow),
                      ),
                      PopupMenuButton(
                        icon: const Icon(Icons.more_vert_rounded, color: AppTheme.textMuted, size: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Text('Edit')),
                          const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppTheme.error))),
                        ],
                        onSelected: (value) {
                          if (value == 'edit') _showForm(plan: plan);
                          if (value == 'delete') _confirmDelete(plan);
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add_rounded, size: 26),
      ),
    );
  }

  void _showForm({dynamic plan}) {
    final nameController = TextEditingController(text: plan?.membershipName ?? '');
    final durationController = TextEditingController(text: plan?.duration.toString() ?? '');
    final priceController = TextEditingController(text: plan?.price.toString() ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
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
            Text(
              plan != null ? 'Edit Plan' : 'Add Plan',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Plan Name', prefixIcon: Icon(Icons.badge_outlined))),
            const SizedBox(height: 14),
            TextField(
              controller: durationController,
              decoration: const InputDecoration(labelText: 'Duration (months)', prefixIcon: Icon(Icons.schedule_outlined)),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Price (\$)', prefixIcon: Icon(Icons.attach_money_rounded)),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final data = {
                    'membership_name': nameController.text.trim(),
                    'duration': int.tryParse(durationController.text) ?? 1,
                    'price': double.tryParse(priceController.text) ?? 0,
                  };

                  final auth = Get.find<AuthController>();
                  final provider = Get.find<MembershipController>();

                  if (plan != null) {
                    await provider.updateMembership(auth, plan.membershipId, data);
                  } else {
                    await provider.createMembership(auth, data);
                  }

                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: Text(plan != null ? 'Update' : 'Create'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(dynamic plan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Plan'),
        content: Text('Delete "${plan.membershipName}" plan?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await Get.find<MembershipController>().deleteMembership(
                Get.find<AuthController>(),
                plan.membershipId,
              );
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}
