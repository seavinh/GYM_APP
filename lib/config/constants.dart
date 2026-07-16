class AppConstants {
  // User Roles
  static const String roleAdmin = 'admin';
  static const String roleReceptionist = 'receptionist';
  static const String roleMember = 'member';

  static const List<String> roles = [
    roleMember,
    roleReceptionist,
    roleAdmin,
  ];

  // Genders
  static const String genderMale = 'male';
  static const String genderFemale = 'female';
  static const String genderOther = 'other';

  static const List<String> genders = [
    genderMale,
    genderFemale,
    genderOther,
  ];

  // Equipment Status
  static const String statusAvailable = 'available';
  static const String statusMaintenance = 'maintenance';
  static const String statusRetired = 'retired';

  static const List<String> equipmentStatuses = [
    statusAvailable,
    statusMaintenance,
    statusRetired,
  ];
}
