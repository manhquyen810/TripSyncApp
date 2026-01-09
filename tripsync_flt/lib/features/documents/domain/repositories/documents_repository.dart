import 'dart:typed_data';

import '../../data/models/document_dto.dart';

abstract interface class DocumentsRepository {
  Future<DocumentDto> uploadDocument({
    required int tripId,
    required String category,
    String? filePath,
    Uint8List? bytes,
    String? filename,
  });

  Future<List<DocumentDto>> listDocumentsByTrip({required int tripId});

  Future<DocumentDto> getDocument({required int documentId});

  Future<void> deleteDocument({required int documentId});

  Future<Uint8List> downloadBytes({required String url});
}
