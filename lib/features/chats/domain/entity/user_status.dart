enum UserStatus { ONLINE, OFFLINE }

class UserConnectionInfo {
  final String nickName;
  final String email;
  final UserStatus status;

  UserConnectionInfo({
    required this.nickName,
    required this.email,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'nickName': nickName,
      'email': email,
      'status': status.toString().split('.').last,
    };
  }
}
