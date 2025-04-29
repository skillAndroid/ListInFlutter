// lib/features/chats/domain/entity/user_status.dart
// lib/features/chats/domain/entity/user_status.dart

// ignore_for_file: constant_identifier_names

enum UserStatus {
  ONLINE,
  OFFLINE,
}

class UserConnectionInfo {
  final String email;
  final String nickName;
  final UserStatus status;

  UserConnectionInfo({
    required this.email,
    required this.nickName,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'nickName': nickName,
      'status': status.toString().split('.').last,
    };
  }

  factory UserConnectionInfo.fromJson(Map<String, dynamic> json) {
    return UserConnectionInfo(
      email: json['email'],
      nickName: json['nickName'],
      status:
          json['status'] == 'ONLINE' ? UserStatus.ONLINE : UserStatus.OFFLINE,
    );
  }

  UserConnectionInfo copyWith({
    String? email,
    String? nickName,
    UserStatus? status,
  }) {
    return UserConnectionInfo(
      email: email ?? this.email,
      nickName: nickName ?? this.nickName,
      status: status ?? this.status,
    );
  }
}
