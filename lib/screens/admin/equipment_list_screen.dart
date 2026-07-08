import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/equipment_provider.dart';

class EquipmentListScreen extends StatefulWidget {
  const EquipmentListScreen({super.key});

  @override
  State<EquipmentListScreen> createState() => _EquipmentListScreenState();
}

class _EquipmentListScreenState extends State<EquipmentListScreen> {
  final _searchController = TextEditingController();
  String _statusFilter = '';

  @override
  void initState() {
    super.initState();
    context.read<EquipmentProvider>().loadEquipment(context.read<AuthProvider>());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Equipment')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search equipment...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                                context.read<EquipmentProvider>().loadEquipment(context.read<AuthProvider>());
                              },
                            )
                          : null,
                    ),
                    onChanged: (v) => setState(() {}),
                    onSubmitted: (v) {
                      context.read<EquipmentProvider>().loadEquipment(
                        context.read<AuthProvider>(),
                        search: v,
                        status: _statusFilter.isEmpty ? null : _statusFilter,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.divider, width: 0.5),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _statusFilter.isEmpty ? null : _statusFilter,
                      dropdownColor: AppTheme.cardDark,
                      hint: const Icon(Icons.filter_list_rounded, color: AppTheme.textMuted, size: 20),
                      items: const [
                        DropdownMenuItem(value: '', child: Text('All')),
                        DropdownMenuItem(value: 'available', child: Text('Available')),
                        DropdownMenuItem(value: 'maintenance', child: Text('Maintenance')),
                        DropdownMenuItem(value: 'retired', child: Text('Retired')),
                      ],
                      onChanged: (v) {
                        setState(() => _statusFilter = v ?? '');
                        context.read<EquipmentProvider>().loadEquipment(
                          context.read<AuthProvider>(),
                          search: _searchController.text,
                          status: _statusFilter.isEmpty ? null : _statusFilter,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<EquipmentProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.equipment.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.accentTeal));
                }

                if (provider.equipment.isEmpty) {
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
                          child: const Icon(Icons.fitness_center_outlined, size: 48, color: AppTheme.textMuted),
                        ),
                        const SizedBox(height: 16),
                        const Text('No equipment found', style: TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  itemCount: provider.equipment.length,
                  itemBuilder: (context, index) {
                    final item = provider.equipment[index];
                    final statusColor = _statusColor(item.status);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: AppTheme.glassCard,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(14),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundColor: statusColor.withAlpha(15),
                          child: Icon(Icons.fitness_center_rounded, color: statusColor, size: 20),
                        ),
                        title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              if (item.type != null) ...[
                                Text(item.type!, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                                const Text('  •  ', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                              ],
                              Text('Qty: ${item.quantity}', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                              const Text('  •  ', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: statusColor.withAlpha(15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(item.status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
                              ),
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
                            if (value == 'edit') _showForm(item: item);
                            if (value == 'delete') _confirmDelete(item);
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

  Color _statusColor(String status) {
    switch (status) {
      case 'available': return AppTheme.success;
      case 'maintenance': return AppTheme.accentYellow;
      case 'retired': return AppTheme.error;
      default: return AppTheme.textSecondary;
    }
  }

  void _showForm({dynamic item}) {
    final nameController = TextEditingController(text: item?.name ?? '');
    final typeController = TextEditingController(text: item?.type ?? '');
    final quantityController = TextEditingController(text: item?.quantity.toString() ?? '');
    String status = item?.status ?? 'available';
    final purchaseDateController = TextEditingController(
      text: item?.purchaseDate != null
          ? '${item.purchaseDate.year}-${item.purchaseDate.month.toString().padLeft(2, '0')}-${item.purchaseDate.day.toString().padLeft(2, '0')}'
          : '',
    );

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
              Text(
                item != null ? 'Edit Equipment' : 'Add Equipment',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.label_outline_rounded))),
              const SizedBox(height: 14),
              TextField(controller: typeController, decoration: const InputDecoration(labelText: 'Type (optional)', prefixIcon: Icon(Icons.category_outlined))),
              const SizedBox(height: 14),
              TextField(controller: quantityController, decoration: const InputDecoration(labelText: 'Quantity', prefixIcon: Icon(Icons.inventory_2_outlined)), keyboardType: TextInputType.number),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: status,
                decoration: const InputDecoration(labelText: 'Status', prefixIcon: Icon(Icons.info_outline_rounded)),
                items: const [
                  DropdownMenuItem(value: 'available', child: Text('Available')),
                  DropdownMenuItem(value: 'maintenance', child: Text('Maintenance')),
                  DropdownMenuItem(value: 'retired', child: Text('Retired')),
                ],
                onChanged: (v) => setSheetState(() => status = v!),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: purchaseDateController,
                decoration: const InputDecoration(labelText: 'Purchase Date (YYYY-MM-DD, optional)', prefixIcon: Icon(Icons.calendar_today_rounded)),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: ctx,
                    initialDate: item?.purchaseDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    purchaseDateController.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                  }
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final data = {
                      'name': nameController.text.trim(),
                      'type': typeController.text.trim().isEmpty ? null : typeController.text.trim(),
                      'quantity': int.tryParse(quantityController.text) ?? 1,
                      'status': status,
                      'purchase_date': purchaseDateController.text.isEmpty ? null : purchaseDateController.text,
                    };

                    final auth = context.read<AuthProvider>();
                    final provider = context.read<EquipmentProvider>();

                    if (item != null) {
                      await provider.updateEquipment(auth, item.equipmentId, data);
                    } else {
                      await provider.createEquipment(auth, data);
                    }

                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: Text(item != null ? 'Update' : 'Create'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(dynamic item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Equipment'),
        content: Text('Remove "${item.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<EquipmentProvider>().deleteEquipment(
                context.read<AuthProvider>(),
                item.equipmentId,
              );
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}
