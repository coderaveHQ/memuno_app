import 'package:memuno_app/src/core/models/items/user_item_entity.dart';
import 'package:memuno_app/src/core/models/pagination/list_cursor_entity.dart';
import 'package:memuno_app/src/core/models/pagination/list_page_entity.dart';
import 'package:memuno_app/src/features/group_details/domain/repositories/group_details_repository.dart';

/// Usecase for loading invitable-friends list in group-details info.
final class ListGroupDetailsInvitableFriendsUsecase {
  const ListGroupDetailsInvitableFriendsUsecase({
    required GroupDetailsRepository repository,
  }) : _repository = repository;

  final GroupDetailsRepository _repository;

  /// Loads one invitable-friends page.
  Future<ListPageEntity<UserItemEntity>> call({
    required String groupId,
    required int limit,
    ListCursorEntity? cursor,
  }) {
    return _repository.listGroupInvitableFriends(
      groupId: groupId,
      limit: limit,
      cursor: cursor,
    );
  }
}
