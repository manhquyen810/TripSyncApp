import '../../data/models/checklist_item_dto.dart';

abstract interface class ChecklistRepository {
  Future<List<ChecklistItemDto>> listTripChecklist({required int tripId});

  Future<ChecklistItemDto> addItem({
    required int tripId,
    required String content,
    int? assigneeId,
  });

  Future<ChecklistItemDto> toggleItem({
    required int itemId,
    required bool isDone,
  });

  Future<ChecklistItemDto> getItem({required int itemId});

  Future<ChecklistItemDto> updateItem({
    required int itemId,
    required String content,
    int? assigneeId,
  });

  Future<void> deleteItem({required int itemId});
}
