class MedicalFile {
  final String bucket;
  final String objectName;
  final String contentType;
  final int size;
  final String lastModified;
  final String downloadUrl;
  final Map<String, dynamic>? metadata;
  final String? filename;

  MedicalFile({
    required this.bucket,
    required this.objectName,
    required this.contentType,
    required this.size,
    required this.lastModified,
    required this.downloadUrl,
    this.metadata,
    this.filename,
  });

  factory MedicalFile.fromJson(Map<String, dynamic> json) {
    // Extract the actual user metadata from the MinIO metadata
    Map<String, dynamic> processedMetadata = {};
    if (json['metadata'] != null) {
      json['metadata'].forEach((key, value) {
        // Extract user-defined metadata from x-amz-meta-* keys
        if (key.startsWith('x-amz-meta-')) {
          // Remove the x-amz-meta- prefix and store the actual metadata
          final metaKey = key.substring('x-amz-meta-'.length);
          processedMetadata[metaKey] = value;
        }
      });
    }

    // Create a structured metadata object with user-friendly values
    final Map<String, dynamic> structuredMetadata = {
      'category': processedMetadata['category'] ?? 'Uncategorized',
      'isMedicallyImportant':
          processedMetadata['isMedicallyImportant'] == 'true',
      'isShared': processedMetadata['isShared'] == 'true',
      'sharedWith': processedMetadata['sharedWith'],
      'uploadedBy': processedMetadata['uploaded_by'],
      'originalFilename': processedMetadata['filename'],
    };

    // Get the filename from either metadata or object_name
    String? filename = json['filename'];
    if (filename == null || filename.isEmpty) {
      // Extract filename from the object_name if it's not provided directly
      final objectName = json['object_name'] as String;
      final parts = objectName.split('/');
      if (parts.isNotEmpty) {
        filename = parts.last;
      }
    }

    return MedicalFile(
      bucket: json['bucket'],
      objectName: json['object_name'],
      contentType: json['content_type'],
      size: json['size'],
      lastModified: json['last_modified'],
      downloadUrl: json['download_url'],
      metadata: structuredMetadata,
      filename: filename,
    );
  }
}
