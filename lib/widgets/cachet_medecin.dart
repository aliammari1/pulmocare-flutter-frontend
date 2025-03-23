import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;

class CachetMedecin extends StatelessWidget {
  final Uint8List? imageBytes;
  final Function(Uint8List) onSelect;
  final double size;

  const CachetMedecin({
    super.key,
    this.imageBytes,
    required this.onSelect,
    this.size = 150,
  });

  Future<void> _pickImage(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();

      // Configuration optimisée pour la sélection d'image
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500, // Réduire la taille maximale
        maxHeight: 500,
        imageQuality: 70, // Augmenter la compression
      );

      if (pickedFile == null) return;

      Uint8List? bytes;

      if (kIsWeb) {
        // Gestion spécifique pour le web
        bytes = await pickedFile.readAsBytes();
      } else {
        // Gestion pour les plateformes natives
        final File file = File(pickedFile.path);
        bytes = await file.readAsBytes();
      }

      if (bytes.isEmpty) {
        throw Exception('Image vide');
      }

      // Vérifier la taille maximum (2 MB)
      if (bytes.length > 2 * 1024 * 1024) {
        throw Exception('Image trop grande (max 2 MB)');
      }

      onSelect(bytes);
    } catch (e) {
      if (context.mounted) {
        // Afficher une erreur plus détaillée
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'importation de l\'image: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Réessayer',
              onPressed: () => _pickImage(context),
              textColor: Colors.white,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _pickImage(context),
          borderRadius: BorderRadius.circular(12),
          child:
              imageBytes != null ? _buildImagePreview() : _buildPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Image.memory(
            imageBytes!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Text(
                  'Erreur de chargement',
                  style: TextStyle(color: Colors.red.shade400),
                ),
              );
            },
          ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit, size: 16, color: Colors.blue.shade700),
                const SizedBox(width: 4),
                Text(
                  'Modifier',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 40,
          color: Colors.blue.shade300,
        ),
        const SizedBox(height: 8),
        Text(
          'Ajouter un cachet',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Cliquez ici',
          style: TextStyle(
            color: Colors.blue.shade700,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
