import '../../domain/repositories/checklist_repository.dart';
import '../datasources/checklist_remote_data_source.dart';
import '../models/checklist_item_dto.dart';

class ChecklistRepositoryImpl implements ChecklistRepository {
  ChecklistRepositoryImpl(this._remote);

  final ChecklistRemoteDataSource _remote;

  @override
  Future<List<ChecklistItemDto>> listTripChecklist({
    required int tripId,
  }) async {
    final raw = await _remote.listTripChecklist(tripId: tripId);
    return _extractItems(raw);
  }

  @override
  Future<ChecklistItemDto> addItem({
    required int tripId,
    required String content,
    int? assigneeId,
  }) async {
    final raw = await _remote.addItem(
      tripId: tripId,
      content: content,
      assigneeId: assigneeId,
    );
    return _extractItem(raw);
  }

  @override
  Future<ChecklistItemDto> toggleItem({
    required int itemId,
    required bool isDone,
  }) async {
    final raw = await _remote.toggleItem(itemId: itemId, isDone: isDone);
    return _extractItem(raw);
  }

  @override
  Future<ChecklistItemDto> getItem({required int itemId}) async {
    final raw = await _remote.getItem(itemId: itemId);
    return _extractItem(raw);
  }

  @override
  Future<ChecklistItemDto> updateItem({
    required int itemId,
    required String content,
    int? assigneeId,
  }) async {
    final raw = await _remote.updateItem(
      itemId: itemId,
      content: content,
      assigneeId: assigneeId,
    );
    return _extractItem(raw);
  }

  @override
  Future<void> deleteItem({required int itemId}) async {
    await _remote.deleteItem(itemId: itemId);
  }

  ChecklistItemDto _extractItem(Map<String, dynamic> raw) {
    final data = raw['data'];
    if (data is Map<String, dynamic>) {
      return ChecklistItemDto.fromJson(data);
    }
    if (data is Map) {
      return ChecklistItemDto.fromJson(Map<String, dynamic>.from(data));
    }

    if (raw.containsKey('id')) {
      return ChecklistItemDto.fromJson(raw);
    }

    throw StateError('Response did not contain checklist item data');
  }

  List<ChecklistItemDto> _extractItems(Map<String, dynamic> raw) {
    final data = raw['data'];
    if (data is List) {
      return data
          .whereType<Object?>()
          .map((e) {
            if (e is Map<String, dynamic>) return ChecklistItemDto.fromJson(e);
            if (e is Map) {
              return ChecklistItemDto.fromJson(Map<String, dynamic>.from(e));
            }
            return null;
          })
          .whereType<ChecklistItemDto>()
          .toList(growable: false);
    }

    return const <ChecklistItemDto>[];
  }
}
