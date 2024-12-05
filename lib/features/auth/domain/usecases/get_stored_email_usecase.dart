import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/auth/domain/entities/retrived_email.dart';
import 'package:list_in/features/auth/domain/repositories/auth_repository.dart';

class GetStoredEmailUsecase extends UseCase<RetrivedEmail?, NoParams> {
  AuthRepository authRepository;
  GetStoredEmailUsecase(this.authRepository);

  @override
  Future<RetrivedEmail?> call({NoParams? params}) async {
    return await authRepository.getStoredEmail();
  }
}
