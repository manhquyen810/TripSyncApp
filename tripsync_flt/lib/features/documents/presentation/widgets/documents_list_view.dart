import 'package:flutter/material.dart';

import '../../../../shared/styles/app_colors.dart';
import '../models/document_item.dart';
import 'document_list_item.dart';

typedef DocumentCategoryLabel = String Function(DocumentCategory category);

typedef DocumentItemCallback = void Function(DocumentItem doc);

typedef DocumentDeleteCallback = Future<void> Function(DocumentItem doc);

class DocumentsListView extends StatelessWidget {
  const DocumentsListView({
    super.key,
    required this.documents,
    required this.categoryLabelFor,
    required this.onTap,
    required this.onDownloadPressed,
    required this.onDeleteRequested,
  });

  final List<DocumentItem> documents;
  final DocumentCategoryLabel categoryLabelFor;
  final DocumentItemCallback onTap;
  final DocumentItemCallback onDownloadPressed;
  final DocumentDeleteCallback onDeleteRequested;

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      return Center(
        child: Text(
          'Chưa có tài liệu',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      itemCount: documents.length,
      itemBuilder: (context, index) {
        final doc = documents[index];
        final card = Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: DocumentListItem(
            doc: doc,
            categoryTitle: categoryLabelFor(doc.category),
            onTap: () => onTap(doc),
            onDownloadPressed: () => onDownloadPressed(doc),
          ),
        );

        final documentId = doc.id;
        if (documentId == null) return card;

        const outerRadius = 24.0;

        return ClipRRect(
          borderRadius: BorderRadius.circular(outerRadius),
          child: Dismissible(
            key: ValueKey<int>(documentId),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) async {
              if (direction != DismissDirection.endToStart) {
                return false;
              }
              await onDeleteRequested(doc);
              // Keep the widget in the tree; it will disappear after refresh.
              return false;
            },
            background: Container(
              color: AppColors.primary,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: card,
          ),
        );
      },
    );
  }
}
