import 'package:dartz/dartz.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/features/auth/domain/entities/auth_tokens.dart';
import 'package:list_in/features/auth/domain/entities/login.dart';
import 'package:list_in/features/auth/domain/entities/retrived_email.dart';
import 'package:list_in/features/auth/domain/entities/signup.dart';
import 'package:list_in/features/auth/domain/entities/user.dart';
import 'package:list_in/features/auth/domain/entities/verify_email.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthToken>> login(Login login);
  Future<Either<Failure, RetrivedEmail>> signup(Signup signup);
  Future<Either<Failure, void>> verifyEmailSignup(VerifyEmail verifyEmail);
  Future<Either<Failure, AuthToken>> registerUserData(User user);
  Future<RetrivedEmail?> getStoredEmail();
  Future<void> deleteRetrivedEmail();
  Future<AuthToken?> getStoredAuthToken();
  Future<void> logout();
}
