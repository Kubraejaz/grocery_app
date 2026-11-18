// lib/models/user_profile.dart
import '../utils/constants.dart';

class UserProfile {
  final String   id;
  final String   fullName;
  final String   email;
  final int      userType; // 1: Admin, 2: Customer / User
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.userType,
    required this.createdAt,
  });

  bool get isAdmin => userType == UserTypes.admin;
  bool get isCustomer => userType == UserTypes.user;
  String get roleLabel => UserTypes.getLabel(userType);

  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
        id:        j['id']        as String,
        fullName:  j['full_name'] as String? ?? 'User',
        email:     j['email']     as String? ?? '',
        userType:  (j['user_type'] as num?)?.toInt() ?? UserTypes.user,
        createdAt: DateTime.parse(
          j['created_at'] as String? ?? DateTime.now().toIso8601String(),
        ),
      );

  Map<String, dynamic> toJson() => {
        'id':         id,
        'full_name':  fullName,
        'email':      email,
        'user_type':  userType,
        'created_at': createdAt.toIso8601String(),
      };
}

