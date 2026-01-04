import 'dart:typed_data';

class DocumentItem {
  final int? id;
  final String title;
  final String author;
  final String date;
  final String iconAsset;
  final DocumentCategory category;
  final String? url;
  final String? localPath;
  final Uint8List? bytes;
  final String? extension;

  const DocumentItem({
    this.id,
    required this.title,
    required this.author,
    required this.date,
    required this.iconAsset,
    required this.category,
    this.url,
    this.localPath,
    this.bytes,
    this.extension,
  });
}

enum DocumentCategory { all, flight, hotel, cccd, bus }
