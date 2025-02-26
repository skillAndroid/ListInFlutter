// 1. Entities
class UserProfile {
  final String userId;
  final String nickName;
  final String profileImagePath;

  UserProfile({
    required this.userId,
    required this.nickName,
    required this.profileImagePath,
  });
}

class PaginatedResponse<T> {
  final int totalElements;
  final int totalPages;
  final int size;
  final List<T> content;
  final int number;
  final List<SortItem> sort;
  final Pageable pageable;
  final int numberOfElements;
  final bool first;
  final bool last;
  final bool empty;

  PaginatedResponse({
    required this.totalElements,
    required this.totalPages,
    required this.size,
    required this.content,
    required this.number,
    required this.sort,
    required this.pageable,
    required this.numberOfElements,
    required this.first,
    required this.last,
    required this.empty,
  });
}

class SortItem {
  final String direction;
  final String nullHandling;
  final bool ascending;
  final String property;
  final bool ignoreCase;

  SortItem({
    required this.direction,
    required this.nullHandling,
    required this.ascending,
    required this.property,
    required this.ignoreCase,
  });
}

class Pageable {
  final int offset;
  final List<SortItem> sort;
  final bool paged;
  final int pageNumber;
  final int pageSize;
  final bool unpaged;

  Pageable({
    required this.offset,
    required this.sort,
    required this.paged,
    required this.pageNumber,
    required this.pageSize,
    required this.unpaged,
  });
}