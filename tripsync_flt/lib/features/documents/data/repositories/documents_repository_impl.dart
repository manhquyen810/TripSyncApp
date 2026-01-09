import 'dart:typed_data';

import '../../../../core/config/env.dart';
import '../../domain/repositories/documents_repository.dart';
import '../datasources/documents_remote_data_source.dart';
import '../models/document_dto.dart';

class DocumentsRepositoryImpl implements DocumentsRepository {
  DocumentsRepositoryImpl(this._remote);

  final DocumentsRemoteDataSource _remote;

  @override
  Future<DocumentDto> uploadDocument({
    required int tripId,
    required String category,
    String? filePath,
    Uint8List? bytes,
    String? filename,
  }) async {
    final raw = await _remote.uploadDocument(
      tripId: tripId,
      category: category,
      filePath: filePath,
      bytes: bytes,
      filename: filename,
    );

    final doc = _extractDocument(raw);
    return doc.copyWith(url: _normalizeUrl(doc.url));
  }

  @override
  Future<List<DocumentDto>> listDocumentsByTrip({required int tripId}) async {
    final raw = await _remote.listDocumentsByTrip(tripId: tripId);
    final docs = _extractDocuments(raw);
    return docs.map((d) => d.copyWith(url: _normalizeUrl(d.url))).toList();
  }

  @override
  Future<DocumentDto> getDocument({required int documentId}) async {
    final raw = await _remote.getDocument(documentId: documentId);
    final doc = _extractDocument(raw);
    return doc.copyWith(url: _normalizeUrl(doc.url));
  }

  @override
  Future<void> deleteDocument({required int documentId}) async {
    await _remote.deleteDocument(documentId: documentId);
  }

  @override
  Future<Uint8List> downloadBytes({required String url}) async {
    return _remote.downloadBytes(url: url);
  }

  DocumentDto _extractDocument(Map<String, dynamic> raw) {
    final data = raw['data'];
    if (data is Map<String, dynamic>) {
      return DocumentDto.fromJson(data);
    }
    if (data is Map) {
      return DocumentDto.fromJson(Map<String, dynamic>.from(data));
    }

    if (raw.containsKey('id')) {
      return DocumentDto.fromJson(raw);
    }

    throw StateError('Response did not contain document data');
  }

  List<DocumentDto> _extractDocuments(Map<String, dynamic> raw) {
    final data = raw['data'];
    if (data is List) {
      return data
          .whereType<Object?>()
          .map((e) {
            if (e is Map<String, dynamic>) return DocumentDto.fromJson(e);
            if (e is Map) {
              return DocumentDto.fromJson(Map<String, dynamic>.from(e));
            }
            return null;
          })
          .whereType<DocumentDto>()
          .toList(growable: false);
    }

    return const <DocumentDto>[];
  }

  String _normalizeUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return trimmed;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (trimmed.startsWith('//')) {
      return 'https:$trimmed';
    }
    if (trimmed.startsWith('assets/')) return trimmed;

    if (trimmed.startsWith('/')) {
      return '${Env.apiBaseUrl}$trimmed';
    }
    return '${Env.apiBaseUrl}/$trimmed';
  }
}

extension on DocumentDto {
  DocumentDto copyWith({
    int? id,
    int? tripId,
    int? uploaderId,
    String? filename,
    String? url,
    String? category,
    DateTime? createdAt,
  }) {
    return DocumentDto(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      uploaderId: uploaderId ?? this.uploaderId,
      filename: filename ?? this.filename,
      url: url ?? this.url,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
