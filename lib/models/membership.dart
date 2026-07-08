class Membership {
  final int membershipId;
  final String membershipName;
  final int duration;
  final double price;

  Membership({
    required this.membershipId,
    required this.membershipName,
    required this.duration,
    required this.price,
  });

  factory Membership.fromJson(Map<String, dynamic> json) {
    return Membership(
      membershipId: json['membership_id'],
      membershipName: json['membership_name'],
      duration: json['duration'],
      price: double.parse(json['price'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'membership_id': membershipId,
      'membership_name': membershipName,
      'duration': duration,
      'price': price,
    };
  }
}
