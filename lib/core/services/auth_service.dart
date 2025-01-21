import 'package:dio/dio.dart';
import 'package:list_in/core/error/exeptions.dart';
import 'package:list_in/features/auth/data/sources/auth_local_data_source.dart';

class AuthService {
  final AuthLocalDataSource authLocalDataSource;

  AuthService({required this.authLocalDataSource});

  Future<Options> getAuthOptions() async {
    final authToken = await authLocalDataSource.getLastAuthToken();
    if (authToken == null) {
      throw UnauthorizedException('No auth token found');
    }
    return Options(
      headers: {
        'Authorization': 'Bearer ${authToken.accessToken}',
        'Content-Type': 'application/json',
        'Connection': 'keep-alive',
      },
    );
  }
}
