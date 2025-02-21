enum FollowStatus { initial, inProgress, success, error }

enum LikeStatus { initial, inProgress, success, error }

enum ViewStatus { initial, inProgress, success, error }

class FollowStatusInfo {
  final FollowStatus status;
  final String? errorMessage;

  const FollowStatusInfo({
    this.status = FollowStatus.initial,
    this.errorMessage,
  });

  FollowStatusInfo copyWith({
    FollowStatus? status,
    String? errorMessage,
  }) {
    return FollowStatusInfo(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class LikeStatusInfo {
  final LikeStatus status;
  final String? errorMessage;

  const LikeStatusInfo({
    this.status = LikeStatus.initial,
    this.errorMessage,
  });

  LikeStatusInfo copyWith({
    LikeStatus? status,
    String? errorMessage,
  }) {
    return LikeStatusInfo(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ViewStatusInfo {
  final ViewStatus status;
  final String? errorMessage;

  const ViewStatusInfo({
    this.status = ViewStatus.initial,
    this.errorMessage,
  });

  ViewStatusInfo copyWith({
    ViewStatus? status,
    String? errorMessage,
  }) {
    return ViewStatusInfo(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

