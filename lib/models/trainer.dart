class Trainer {
  final int trainerId;
  final String trainerName;
  final String phone;
  final String? specialty;

  Trainer({
    required this.trainerId,
    required this.trainerName,
    required this.phone,
    this.specialty,
  });

  factory Trainer.fromJson(Map<String, dynamic> json) {
    return Trainer(
      trainerId: json['trainer_id'],
      trainerName: json['trainer_name'],
      phone: json['phone'],
      specialty: json['specialty'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trainer_id': trainerId,
      'trainer_name': trainerName,
      'phone': phone,
      'specialty': specialty,
    };
  }
}
