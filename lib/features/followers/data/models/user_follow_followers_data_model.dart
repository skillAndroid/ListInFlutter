import 'package:list_in/features/followers/domain/entity/user_followings_followers_data.dart';

class UserProfileModel {
  final String userId;
  final String nickName;
  final String profileImagePath;

  UserProfileModel({
    required this.userId,
    required this.nickName,
    required this.profileImagePath,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      userId: json['userId'],
      nickName: json['nickName'],
      profileImagePath: json['profileImagePath'],
    );
  }

  UserProfile toEntity() {
    return UserProfile(
      userId: userId,
      nickName: nickName,
      profileImagePath: profileImagePath,
    );
  }
}

class SortItemModel {
  final String direction;
  final String nullHandling;
  final bool ascending;
  final String property;
  final bool ignoreCase;

  SortItemModel({
    required this.direction,
    required this.nullHandling,
    required this.ascending,
    required this.property,
    required this.ignoreCase,
  });

  factory SortItemModel.fromJson(Map<String, dynamic> json) {
    return SortItemModel(
      direction: json['direction'],
      nullHandling: json['nullHandling'],
      ascending: json['ascending'],
      property: json['property'],
      ignoreCase: json['ignoreCase'],
    );
  }

  SortItem toEntity() {
    return SortItem(
      direction: direction,
      nullHandling: nullHandling,
      ascending: ascending,
      property: property,
      ignoreCase: ignoreCase,
    );
  }
}

class PageableModel {
  final int offset;
  final List<SortItemModel> sort;
  final bool paged;
  final int pageNumber;
  final int pageSize;
  final bool unpaged;

  PageableModel({
    required this.offset,
    required this.sort,
    required this.paged,
    required this.pageNumber,
    required this.pageSize,
    required this.unpaged,
  });

  factory PageableModel.fromJson(Map<String, dynamic> json) {
    var sortList = (json['sort'] as List?)?.map((e) => SortItemModel.fromJson(e)).toList() ?? [];

    return PageableModel(
      offset: json['offset'],
      sort: sortList,
      paged: json['paged'],
      pageNumber: json['pageNumber'],
      pageSize: json['pageSize'],
      unpaged: json['unpaged'],
    );
  }

  Pageable toEntity() {
    return Pageable(
      offset: offset,
      sort: sort.map((e) => e.toEntity()).toList(),
      paged: paged,
      pageNumber: pageNumber,
      pageSize: pageSize,
      unpaged: unpaged,
    );
  }
}

class PaginatedResponseModel<T> {
  final int totalElements;
  final int totalPages;
  final int size;
  final List<dynamic> content;
  final int number;
  final List<SortItemModel> sort;
  final PageableModel pageable;
  final int numberOfElements;
  final bool first;
  final bool last;
  final bool empty;

  PaginatedResponseModel({
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

  factory PaginatedResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    var contentList = (json['content'] as List?)
        ?.map((item) => fromJsonT(item as Map<String, dynamic>))
        .toList() ?? [];
        
    var sortList = (json['sort'] as List?)
        ?.map((e) => SortItemModel.fromJson(e as Map<String, dynamic>))
        .toList() ?? [];

    return PaginatedResponseModel<T>(
      totalElements: json['totalElements'],
      totalPages: json['totalPages'],
      size: json['size'],
      content: contentList,
      number: json['number'],
      sort: sortList,
      pageable: PageableModel.fromJson(json['pageable']),
      numberOfElements: json['numberOfElements'],
      first: json['first'],
      last: json['last'],
      empty: json['empty'],
    );
  }

  PaginatedResponse<R> toEntity<R>(R Function(dynamic) mapper) {
    return PaginatedResponse<R>(
      totalElements: totalElements,
      totalPages: totalPages,
      size: size,
      content: content.map((e) => mapper(e)).toList(),
      number: number,
      sort: sort.map((e) => e.toEntity()).toList(),
      pageable: pageable.toEntity(),
      numberOfElements: numberOfElements,
      first: first,
      last: last,
      empty: empty,
    );
  }
}