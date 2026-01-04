import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/document_dto.dart';

class CachedDocument {
  final DocumentDto dto;
  final String? localPath;

  const CachedDocument({required this.dto, this.localPath});
}

class DocumentOfflineStore {
  static const String _tripListPrefix = 'docs_cache_trip_';
  static const String _docPathPrefix = 'docs_cache_path_';

  Future<void> saveTripDocuments({
    required int tripId,
    required List<DocumentDto> docs,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final list = <Map<String, dynamic>>[];
    for (final d in docs) {
      final localPath = prefs.getString(_docPathKey(d.id));
      list.add(<String, dynamic>{
        ...d.toJson(),
        if (localPath != null && localPath.isNotEmpty) 'local_path': localPath,
      });
    }

    await prefs.setString(_tripKey(tripId), jsonEncode(list));
  }

  Future<List<CachedDocument>?> loadTripDocuments({required int tripId}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_tripKey(tripId));
    if (raw == null || raw.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return null;

      final items = <CachedDocument>[];
      for (final e in decoded) {
        if (e is Map<String, dynamic>) {
          final dto = DocumentDto.fromJson(e);
          final localPath = e['local_path'] is String ? (e['local_path'] as String) : null;
          items.add(CachedDocument(dto: dto, localPath: localPath));
        } else if (e is Map) {
          final map = Map<String, dynamic>.from(e);
          final dto = DocumentDto.fromJson(map);
          final localPath = map['local_path'] is String ? (map['local_path'] as String) : null;
          items.add(CachedDocument(dto: dto, localPath: localPath));
        }
      }

      return items;
    } catch (_) {
      return null;
    }
  }

  Future<String?> getLocalPath({required int documentId}) async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_docPathKey(documentId));
    if (path == null || path.trim().isEmpty) return null;
    return path;
  }

  Future<void> setLocalPath({required int documentId, required String localPath}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_docPathKey(documentId), localPath);
  }

  Future<void> clearLocalPath({required int documentId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_docPathKey(documentId));
  }

  Future<File?> getExistingLocalFile({required int documentId}) async {
    final path = await getLocalPath(documentId: documentId);
    if (path == null) return null;

    final file = File(path);
    if (!await file.exists()) return null;
    return file;
  }

  Future<File> persistBytes({
    required int tripId,
    required int documentId,
    required String filename,
    required Uint8List bytes,
  }) async {
    final dir = await _documentsDirForTrip(tripId);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final safeName = _sanitizeFilename(filename);
    final file = File('${dir.path}${Platform.pathSeparator}${documentId}_$safeName');
    await file.writeAsBytes(bytes, flush: true);

    await setLocalPath(documentId: documentId, localPath: file.path);
    return file;
  }

  Future<Directory> _documentsDirForTrip(int tripId) async {
    final base = await getApplicationDocumentsDirectory();
    return Directory(
      '${base.path}${Platform.pathSeparator}tripsync${Platform.pathSeparator}documents${Platform.pathSeparator}trip_$tripId',
    );
  }

  String _tripKey(int tripId) => '$_tripListPrefix$tripId';

  String _docPathKey(int documentId) => '$_docPathPrefix$documentId';

  String _sanitizeFilename(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return 'document';

    // Keep it simple: replace reserved path characters.
    return trimmed.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
  }
}
