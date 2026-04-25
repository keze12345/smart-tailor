import 'package:flutter/material.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../app_state.dart';

class StyleCard extends StatelessWidget {
  final Map post;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  const StyleCard({super.key, required this.post, required this.onTap, this.onEdit, this.onDelete});

  Future<void> _saveImage(BuildContext context, String imageUrl) async {
    try {
      final status = await Permission.storage.request();
      if (!status.isGranted) await Permission.photos.request();
      final response = await http.get(Uri.parse(imageUrl));
      final saved = await SaverGallery.saveImage(
        response.bodyBytes,
        name: 'smart_tailor_style_${DateTime.now().millisecondsSinceEpoch}',
        androidRelativePath: 'Pictures/SmartTailor',
        androidExistNotSave: false,
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(saved.isSuccess ? '✅ Saved to gallery!' : 'Failed to save'),
        backgroundColor: saved.isSuccess ? const Color(0xFF1B5E20) : Colors.red));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')));
    }
  }

  void _openFullScreen(BuildContext context, String imageUrl) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => _FullScreenImage(
        imageUrl: imageUrl,
        title: post['title'] ?? '',
        onSave: () => _saveImage(context, imageUrl),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = post['image_url'] ?? '';
    final appState = Provider.of<AppState>(context, listen: false);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16)),
                    child: imageUrl.isNotEmpty
                      ? Image.network(imageUrl,
                          fit: BoxFit.cover, width: double.infinity,
                          errorBuilder: (_, __, ___) => _placeholder())
                      : _placeholder(),
                  ),
                  // Action buttons
                  if (imageUrl.isNotEmpty)
                    Positioned(
                      top: 8, right: 8,
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () => _openFullScreen(context, imageUrl),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle),
                              child: const Icon(Icons.fullscreen,
                                color: Colors.white, size: 16),
                            ),
                          ),
                          if (!appState.isTailor) ...[
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: () => _saveImage(context, imageUrl),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  shape: BoxShape.circle),
                                child: const Icon(Icons.download_outlined,
                                  color: Colors.white, size: 16),
                              ),
                            ),
                          ],
                          if (onEdit != null) ...[
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: onEdit,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.8),
                                  shape: BoxShape.circle),
                                child: const Icon(Icons.edit_outlined,
                                  color: Colors.white, size: 16),
                              ),
                            ),
                          ],
                          if (onDelete != null) ...[
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: onDelete,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.8),
                                  shape: BoxShape.circle),
                                child: const Icon(Icons.delete_outline,
                                  color: Colors.white, size: 16),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post['title'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w600,
                      fontSize: 13, color: Color(0xFF1C1C1E)),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(8)),
                        child: Text(post['category'] ?? '',
                          style: const TextStyle(fontSize: 10,
                            color: Color(0xFF1B5E20),
                            fontWeight: FontWeight.w600)),
                      ),
                      if ((post['price'] ?? 0) > 0) ...[
                        const Spacer(),
                        Text('${post['price']?.toStringAsFixed(0)} F',
                          style: const TextStyle(fontSize: 11,
                            color: Color(0xFF8E8E93),
                            fontWeight: FontWeight.w500)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFE8F5E9),
      child: Center(
        child: Icon(Icons.checkroom_outlined, size: 48,
          color: const Color(0xFF1B5E20).withOpacity(0.4)),
      ),
    );
  }
}

class _FullScreenImage extends StatelessWidget {
  final String imageUrl;
  final String title;
  final VoidCallback onSave;

  const _FullScreenImage({
    required this.imageUrl,
    required this.title,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(title,
          style: const TextStyle(color: Colors.white, fontSize: 14)),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined, color: Colors.white),
            onPressed: () {
              onSave();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(imageUrl, fit: BoxFit.contain),
            ),
          ),
          Positioned(
            bottom: 32, left: 0, right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  onSave();
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B5E20),
                    borderRadius: BorderRadius.circular(30)),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.download_outlined, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Save to Gallery',
                        style: TextStyle(color: Colors.white,
                          fontWeight: FontWeight.w700, fontSize: 15)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
