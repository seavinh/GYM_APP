import 'member.dart';
import 'membership.dart';

class Payment {
  final int paymentId;
  final int memberId;
  final int membershipId;
  final double amount;
  final DateTime paymentDate;
  final Member? member;
  final Membership? membership;

  Payment({
    required this.paymentId,
    required this.memberId,
    required this.membershipId,
    required this.amount,
    required this.paymentDate,
    this.member,
    this.membership,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      paymentId: json['payment_id'],
      memberId: json['member_id'],
      membershipId: json['membership_id'],
      amount: double.parse(json['amount'].toString()),
      paymentDate: DateTime.parse(json['payment_date']),
      member: json['member'] != null ? Member.fromJson(json['member']) : null,
      membership: json['membership'] != null ? Membership.fromJson(json['membership']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_id': paymentId,
      'member_id': memberId,
      'membership_id': membershipId,
      'amount': amount,
      'payment_date': paymentDate.toIso8601String().substring(0, 10),
    };
  }
}
