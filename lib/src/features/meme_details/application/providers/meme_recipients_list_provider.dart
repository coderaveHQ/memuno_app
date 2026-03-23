import 'package:memuno_app/src/core/models/pagination/list_cursor_entity.dart';
import 'package:memuno_app/src/core/models/pagination/list_page_entity.dart';
import 'package:memuno_app/src/core/state/optimistic/optimistic_async_state_mixin.dart';
import 'package:memuno_app/src/core/state/pagination/async_pagination_mixin.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_list_state.dart';
import 'package:memuno_app/src/core/state/pagination/paginated_page.dart';
import 'package:memuno_app/src/features/meme_details/application/providers/usecases/list_meme_recipients_usecase_provider.dart';
import 'package:memuno_app/src/features/meme_details/application/providers/usecases/remove_meme_recipient_usecase_provider.dart';
import 'package:memuno_app/src/features/meme_details/domain/entities/meme_recipient_target_item_entity.dart';
import 'package:memuno_app/src/features/meme_details/domain/usecases/list_meme_recipients_usecase.dart';
import 'package:memuno_app/src/features/meme_details/domain/usecases/remove_meme_recipient_usecase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'meme_recipients_list_provider.g.dart';

/// Async paginated controller for one meme recipient-target list.
@Riverpod(keepAlive: true)
class MemeRecipientsList extends _$MemeRecipientsList
    with
        AsyncPaginationMixin<MemeRecipientTargetItemEntity, ListCursorEntity>,
        OptimisticAsyncStateMixin<
          PaginatedListState<MemeRecipientTargetItemEntity, ListCursorEntity>
        > {
  @override
  Future<PaginatedListState<MemeRecipientTargetItemEntity, ListCursorEntity>>
  build(String memeId) {
    return buildPaginatedState();
  }

  @override
  Future<PaginatedPage<MemeRecipientTargetItemEntity, ListCursorEntity>>
  loadPage({required int limit, ListCursorEntity? cursor}) async {
    final ListMemeRecipientsUsecase usecase = ref.watch(
      listMemeRecipientsUsecaseProvider,
    );

    final ListPageEntity<MemeRecipientTargetItemEntity> page = await usecase(
      memeId: memeId,
      limit: limit,
      cursor: cursor,
    );

    return PaginatedPage<MemeRecipientTargetItemEntity, ListCursorEntity>(
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

  /// Removes one recipient row optimistically.
  ///
  /// Returns true when the meme was deleted by the DB trigger after removal.
  Future<bool> removeRecipient(MemeRecipientTargetItemEntity recipient) async {
    final PaginatedListState<MemeRecipientTargetItemEntity, ListCursorEntity>?
    current = state.asData?.value;
    if (current == null) {
      return false;
    }

    final int originalIndex = current.items.indexWhere((
      MemeRecipientTargetItemEntity item,
    ) {
      return item.type == recipient.type && item.id == recipient.id;
    });
    if (originalIndex < 0) {
      return false;
    }

    return runOptimisticUpdate<bool>(
      apply:
          (
            PaginatedListState<MemeRecipientTargetItemEntity, ListCursorEntity>
            state,
          ) {
            return _removeRecipientFromState(state, recipient: recipient);
          },
      rollback:
          (
            PaginatedListState<MemeRecipientTargetItemEntity, ListCursorEntity>
            state,
          ) {
            return _restoreRecipientInState(
              state: state,
              recipient: recipient,
              originalIndex: originalIndex,
            );
          },
      operation: () async {
        final RemoveMemeRecipientUsecase usecase = ref.read(
          removeMemeRecipientUsecaseProvider,
        );

        return usecase(
          memeId: memeId,
          targetType: recipient.type,
          targetId: recipient.id,
        );
      },
    );
  }

  PaginatedListState<MemeRecipientTargetItemEntity, ListCursorEntity>
  _removeRecipientFromState(
    PaginatedListState<MemeRecipientTargetItemEntity, ListCursorEntity> state, {
    required MemeRecipientTargetItemEntity recipient,
  }) {
    final List<MemeRecipientTargetItemEntity> nextItems = state.items
        .where((MemeRecipientTargetItemEntity item) {
          return !(item.type == recipient.type && item.id == recipient.id);
        })
        .toList(growable: false);

    return state.copyWith(
      items: List<MemeRecipientTargetItemEntity>.unmodifiable(nextItems),
    );
  }

  PaginatedListState<MemeRecipientTargetItemEntity, ListCursorEntity>
  _restoreRecipientInState({
    required PaginatedListState<MemeRecipientTargetItemEntity, ListCursorEntity>
    state,
    required MemeRecipientTargetItemEntity recipient,
    required int originalIndex,
  }) {
    final bool alreadyPresent = state.items.any((
      MemeRecipientTargetItemEntity item,
    ) {
      return item.type == recipient.type && item.id == recipient.id;
    });
    if (alreadyPresent) {
      return state;
    }

    final List<MemeRecipientTargetItemEntity> nextItems =
        List<MemeRecipientTargetItemEntity>.of(state.items, growable: true);
    final int safeIndex = originalIndex.clamp(0, nextItems.length);
    nextItems.insert(safeIndex, recipient);

    return state.copyWith(
      items: List<MemeRecipientTargetItemEntity>.unmodifiable(nextItems),
    );
  }

  ListCursorEntity? _cursorFromPage(
    ListPageEntity<MemeRecipientTargetItemEntity> page,
  ) {
    final DateTime? createdAt = page.nextCursorCreatedAt;
    final String? id = page.nextCursorId;
    if (createdAt == null || id == null) {
      return null;
    }

    return ListCursorEntity(createdAt: createdAt, id: id);
  }
}
