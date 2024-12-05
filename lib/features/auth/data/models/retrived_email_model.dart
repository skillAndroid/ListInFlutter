import 'package:list_in/features/auth/domain/entities/retrived_email.dart';

class RetrivedEmailModel extends RetrivedEmail {
  RetrivedEmailModel({required super.email});
  factory RetrivedEmailModel.fromJson(Map<String, dynamic> json) {
    return RetrivedEmailModel(email: json['email'] as String);
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }
}
