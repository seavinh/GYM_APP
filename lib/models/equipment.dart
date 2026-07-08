class Equipment {
  final int equipmentId;
  final String name;
  final String? type;
  final int quantity;
  final String status;
  final DateTime? purchaseDate;

  Equipment({
    required this.equipmentId,
    required this.name,
    this.type,
    required this.quantity,
    required this.status,
    this.purchaseDate,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      equipmentId: json['equipment_id'],
      name: json['name'],
      type: json['type'],
      quantity: json['quantity'],
      status: json['status'],
      purchaseDate: json['purchase_date'] != null ? DateTime.parse(json['purchase_date']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'equipment_id': equipmentId,
      'name': name,
      'type': type,
      'quantity': quantity,
      'status': status,
      'purchase_date': purchaseDate?.toIso8601String().substring(0, 10),
    };
  }
}
