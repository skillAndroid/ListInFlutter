import 'package:image_picker/image_picker.dart';
import 'package:list_in/features/profile/domain/entity/user_profile_entity.dart';

abstract class UserProfileEvent {}

class UpdateUserProfileWithImage extends UserProfileEvent {
  final UserProfileEntity profile;
  final XFile? imageFile;  // Optional because update might not always include image
  UpdateUserProfileWithImage({
    required this.profile,
    this.imageFile,
  });
}

class GetUserData extends UserProfileEvent {}