import 'dart:typed_data';

class DocumentItem {
  final String title;
  final String author;
  final String date;
  final String iconAsset;
  final DocumentCategory category;
  final Uint8List? bytes;
  final String? extension;

  const DocumentItem({
    required this.title,
    required this.author,
    required this.date,
    required this.iconAsset,
    required this.category,
    this.bytes,
    this.extension,
  });
}

enum DocumentCategory { all, flight, hotel, cccd, bus }
