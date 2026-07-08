import 'trainer.dart';
import 'payment.dart';

class Member {
  final int memberId;
  final int? userId;
  final String fullName;
  final String gender;
  final DateTime dob;
  final String phone;
  final String email;
  final String? address;
  final DateTime joinDate;
  final String? role;
  final List<Trainer>? trainers;
  final List<Payment>? payments;

  Member({
    required this.memberId,
    this.userId,
    required this.fullName,
    required this.gender,
    required this.dob,
    required this.phone,
    required this.email,
    this.address,
    required this.joinDate,
    this.role,
    this.trainers,
    this.payments,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      memberId: json['member_id'],
      userId: json['user_id'],
      fullName: json['full_name'],
      gender: json['gender'],
      dob: DateTime.parse(json['dob']),
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      joinDate: DateTime.parse(json['join_date']),
      role: json['user']?['role'],
      trainers: json['trainers'] != null
          ? (json['trainers'] as List).map((t) => Trainer.fromJson(t)).toList()
          : null,
      payments: json['payments'] != null
          ? (json['payments'] as List).map((p) => Payment.fromJson(p)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'member_id': memberId,
      'user_id': userId,
      'full_name': fullName,
      'gender': gender,
      'dob': dob.toIso8601String().substring(0, 10),
      'phone': phone,
      'email': email,
      'address': address,
      'join_date': joinDate.toIso8601String().substring(0, 10),
    };
  }
}
