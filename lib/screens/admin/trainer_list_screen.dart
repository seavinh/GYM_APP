import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/trainer_controller.dart';

class TrainerListScreen extends StatefulWidget {
  const TrainerListScreen({super.key});

  @override
  State<TrainerListScreen> createState() => _TrainerListScreenState();
}

class _TrainerListScreenState extends State<TrainerListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Get.find<TrainerController>().loadTrainers(Get.find<AuthController>());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trainers')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search trainers...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          Get.find<TrainerController>().loadTrainers(Get.find<AuthController>());
                        },
                      )
                    : null,
              ),
              onChanged: (v) => setState(() {}),
              onSubmitted: (v) {
                Get.find<TrainerController>().loadTrainers(Get.find<AuthController>(), search: v);
              },
            ),
          ),
          Expanded(
            child: GetBuilder<TrainerController>(
              builder: (trainerProvider) {
                if (trainerProvider.isLoading && trainerProvider.trainers.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.accentTeal));
                }

                if (trainerProvider.trainers.isEmpty) {
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
                          child: const Icon(Icons.sports_martial_arts_outlined, size: 48, color: AppTheme.textMuted),
                        ),
                        const SizedBox(height: 16),
                        const Text('No trainers found', style: TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  itemCount: trainerProvider.trainers.length,
                  itemBuilder: (context, index) {
                    final trainer = trainerProvider.trainers[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: AppTheme.glassCard,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(14),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: AppTheme.accentPink.withAlpha(15),
                          child: const Icon(Icons.sports_martial_arts, color: AppTheme.accentPink, size: 20),
                        ),
                        title: Text(trainer.trainerName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.phone_outlined, size: 12, color: AppTheme.textMuted),
                                  const SizedBox(width: 4),
                                  Text(trainer.phone, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                                ],
                              ),
                              if (trainer.specialty != null && trainer.specialty!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.star_outline, size: 12, color: AppTheme.textMuted),
                                    const SizedBox(width: 4),
                                    Text(trainer.specialty!, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        trailing: PopupMenuButton(
                          icon: const Icon(Icons.more_vert_rounded, color: AppTheme.textMuted, size: 20),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppTheme.error))),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') _showForm(trainer: trainer);
                            if (value == 'delete') _confirmDelete(trainer);
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
        onPressed: () => _showForm(),
        child: const Icon(Icons.add_rounded, size: 26),
      ),
    );
  }

  void _showForm({dynamic trainer}) {
    final nameController = TextEditingController(text: trainer?.trainerName ?? '');
    final phoneController = TextEditingController(text: trainer?.phone ?? '');
    final specialtyController = TextEditingController(text: trainer?.specialty ?? '');

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
              trainer != null ? 'Edit Trainer' : 'Add Trainer',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person_outline_rounded))),
            const SizedBox(height: 14),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone_outlined))),
            const SizedBox(height: 14),
            TextField(controller: specialtyController, decoration: const InputDecoration(labelText: 'Specialty (optional)', prefixIcon: Icon(Icons.star_outline_rounded))),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final data = {
                    'trainer_name': nameController.text.trim(),
                    'phone': phoneController.text.trim(),
                    'specialty': specialtyController.text.trim().isEmpty ? null : specialtyController.text.trim(),
                  };

                  final auth = Get.find<AuthController>();
                  final provider = Get.find<TrainerController>();

                  if (trainer != null) {
                    await provider.updateTrainer(auth, trainer.trainerId, data);
                  } else {
                    await provider.createTrainer(auth, data);
                  }

                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: Text(trainer != null ? 'Update' : 'Create'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(dynamic trainer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Trainer'),
        content: Text('Remove ${trainer.trainerName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await Get.find<TrainerController>().deleteTrainer(
                Get.find<AuthController>(),
                trainer.trainerId,
              );
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}
