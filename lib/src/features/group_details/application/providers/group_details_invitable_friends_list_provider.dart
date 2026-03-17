import 'package:memuno_app/src/core/models/items/user_item_entity.dart';
import 'package:memuno_app/src/core/models/pagination/list_cursor_entity.dart';
import 'package:memuno_app/src/core/models/pagination/list_page_entity.dart';
import 'package:memuno_app/src/core/state/pagination/async_pagination_mixin.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_list_state.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_page.dart';
import 'package:memuno_app/src/features/group_details/application/providers/usecases/list_group_details_invitable_friends_usecase_provider.dart';
import 'package:memuno_app/src/features/group_details/domain/usecases/list_group_details_invitable_friends_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group_details_invitable_friends_list_provider.g.dart';

/// Async paginated controller for invitable friends in group-details info.
@Riverpod(keepAlive: true)
class GroupDetailsInvitableFriendsList
    extends _$GroupDetailsInvitableFriendsList
    with AsyncPaginationMixin<UserItemEntity, ListCursorEntity> {
  @override
  Future<PaginatedListState<UserItemEntity, ListCursorEntity>> build(
    String groupId,
  ) {
    return buildPaginatedState();
  }

  @override
  Future<PaginatedPage<UserItemEntity, ListCursorEntity>> loadPage({
    required int limit,
    ListCursorEntity? cursor,
  }) async {
    final ListGroupDetailsInvitableFriendsUsecase usecase = ref.watch(
      listGroupDetailsInvitableFriendsUsecaseProvider,
    );
    final ListPageEntity<UserItemEntity> page = await usecase(
      groupId: groupId,
      limit: limit,
      cursor: cursor,
    );

    return PaginatedPage<UserItemEntity, ListCursorEntity>(
      items: page.items,
      nextCursor: _cursorFromPage(page),
    );
  }

  /// Refreshes the list from page 1.
  Future<void> refresh() {
    return refreshPage();
  }

  /// Loads and appends the next list page.
  Future<void> loadMore() {
    return loadNextPage();
  }

  ListCursorEntity? _cursorFromPage(ListPageEntity<UserItemEntity> page) {
    final DateTime? createdAt = page.nextCursorCreatedAt;
    final String? id = page.nextCursorId;
    if (createdAt == null || id == null) {
      return null;
    }

    return ListCursorEntity(createdAt: createdAt, id: id);
  }
}
