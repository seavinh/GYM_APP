import 'member.dart';

class Attendance {
  final int attendanceId;
  final int memberId;
  final DateTime checkIn;
  final DateTime? checkOut;
  final Member? member;

  Attendance({
    required this.attendanceId,
    required this.memberId,
    required this.checkIn,
    this.checkOut,
    this.member,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      attendanceId: json['attendance_id'],
      memberId: json['member_id'],
      checkIn: DateTime.parse(json['check_in']),
      checkOut: json['check_out'] != null ? DateTime.parse(json['check_out']) : null,
      member: json['member'] != null ? Member.fromJson(json['member']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendance_id': attendanceId,
      'member_id': memberId,
      'check_in': checkIn.toIso8601String(),
      'check_out': checkOut?.toIso8601String(),
    };
  }
}
