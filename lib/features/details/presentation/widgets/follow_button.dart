import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/visitior_profile/presentation/bloc/another_user_profile_bloc.dart';
import 'package:list_in/features/visitior_profile/presentation/bloc/another_user_profile_state.dart';
import 'package:list_in/global/global_bloc.dart';

class FollowButton extends StatelessWidget {
  final String userId;

  const FollowButton({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GlobalBloc, GlobalState>(
      builder: (context, state) {
        final isFollowed = state.isUserFollowed(userId);
        final followStatus = state.getFollowStatus(userId);
        final isLoading = followStatus == FollowStatus.inProgress;
        // // Show loading spinner while operation is in progress
        if (isLoading) {
          return const Padding(
            padding: EdgeInsets.only(top: 4, left: 16),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(top: 4, left: 16),
          child: InkWell(
            onTap: () {
              context.read<GlobalBloc>().add(UpdateFollowStatusEvent(
  userId: userId,
  isFollowed: isFollowed,
  context: context,
));
            },
            child: Text(
              isFollowed ? 'Unfollow' : 'Follow',
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }
}
