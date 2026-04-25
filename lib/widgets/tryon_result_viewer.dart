import 'dart:io';
import 'package:flutter/material.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class TryOnResultViewer extends StatefulWidget {
  final String? imageUrl;
  final String? imagePath;
  final String title;

  const TryOnResultViewer({
    super.key,
    this.imageUrl,
    this.imagePath,
    this.title = 'Your Look',
  });

  @override
  State<TryOnResultViewer> createState() => _TryOnResultViewerState();
}

class _TryOnResultViewerState extends State<TryOnResultViewer> {
  Color _bgColor = Colors.white;

  final List<Color> _colors = [
    Colors.white,
    const Color(0xFFF2F2F7),
    const Color(0xFFE8F5E9),
    const Color(0xFFE3F2FD),
    const Color(0xFFFFF3E0),
    const Color(0xFFFCE4EC),
    const Color(0xFF1C1C1E),
    const Color(0xFF1B5E20),
    const Color(0xFF0D47A1),
    const Color(0xFF880E4F),
  ];

  Widget _buildImage({double? height, BoxFit fit = BoxFit.contain}) {
    if (widget.imagePath != null && widget.imagePath!.isNotEmpty) {
      return Image.file(File(widget.imagePath!),
        height: height, fit: fit, width: double.infinity);
    }
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      return Image.network(widget.imageUrl!,
        height: height, fit: fit, width: double.infinity);
    }
    return const SizedBox();
  }

  Future<void> _saveToGallery(BuildContext context) async {
    try {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        final photos = await Permission.photos.request();
        if (!photos.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Storage permission denied')));
          return;
        }
      }
      final name = 'smart_tailor_${DateTime.now().millisecondsSinceEpoch}';
      SaveResult? saved;
      if (widget.imagePath != null && widget.imagePath!.isNotEmpty) {
        saved = await SaverGallery.saveFile(
          file: widget.imagePath!,
          name: name,
          androidRelativePath: 'Pictures/SmartTailor',
          androidExistNotSave: false,
        );
      } else if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
        final response = await http.get(Uri.parse(widget.imageUrl!));
        saved = await SaverGallery.saveImage(
          response.bodyBytes,
          name: name,
          androidRelativePath: 'Pictures/SmartTailor',
          androidExistNotSave: false,
        );
      }
      if (saved?.isSuccess == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Saved to gallery!'),
            backgroundColor: Color(0xFF1B5E20)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save image')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving: $e')));
    }
  }

  void _openFullScreen(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => _FullScreenViewer(
        imageUrl: widget.imageUrl,
        imagePath: widget.imagePath,
        title: widget.title,
        bgColor: _bgColor,
        colors: _colors,
        onSave: () => _saveToGallery(context),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Try-on image with selected background
        GestureDetector(
          onTap: () => _openFullScreen(context),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: 320,
                decoration: BoxDecoration(
                  color: _bgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E5EA)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _buildImage(height: 320, fit: BoxFit.contain),
                ),
              ),
              // AI badge
              Positioned(
                top: 12, left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20)),
                  child: const Row(children: [
                    Icon(Icons.auto_awesome, color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Text('AI Try-On',
                      style: TextStyle(color: Colors.white, fontSize: 11)),
                  ]),
                ),
              ),
              // Expand hint
              Positioned(
                top: 12, right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20)),
                  child: const Row(children: [
                    Icon(Icons.fullscreen, color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Text('Tap to expand',
                      style: TextStyle(color: Colors.white, fontSize: 11)),
                  ]),
                ),
              ),
              // Save button
              Positioned(
                bottom: 12, right: 12,
                child: GestureDetector(
                  onTap: () => _saveToGallery(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B5E20),
                      borderRadius: BorderRadius.circular(20)),
                    child: const Row(children: [
                      Icon(Icons.download_outlined, color: Colors.white, size: 14),
                      SizedBox(width: 6),
                      Text('Save', style: TextStyle(color: Colors.white,
                        fontSize: 12, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Background color picker
        const Text('Background color',
          style: TextStyle(fontSize: 12, color: Color(0xFF8E8E93),
            fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        SizedBox(
          height: 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _colors.length,
            itemBuilder: (ctx, i) {
              final color = _colors[i];
              final selected = _bgColor == color;
              return GestureDetector(
                onTap: () => setState(() => _bgColor = color),
                child: Container(
                  width: 36, height: 36,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                        ? const Color(0xFF1B5E20)
                        : const Color(0xFFE5E5EA),
                      width: selected ? 2.5 : 1),
                    boxShadow: [BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4)],
                  ),
                  child: selected
                    ? const Icon(Icons.check, size: 16, color: Color(0xFF1B5E20))
                    : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FullScreenViewer extends StatefulWidget {
  final String? imageUrl;
  final String? imagePath;
  final String title;
  final Color bgColor;
  final List<Color> colors;
  final VoidCallback onSave;

  const _FullScreenViewer({
    this.imageUrl,
    this.imagePath,
    required this.title,
    required this.bgColor,
    required this.colors,
    required this.onSave,
  });

  @override
  State<_FullScreenViewer> createState() => _FullScreenViewerState();
}

class _FullScreenViewerState extends State<_FullScreenViewer> {
  late Color _bgColor;

  @override
  void initState() {
    super.initState();
    _bgColor = widget.bgColor;
  }

  Widget _buildImage() {
    if (widget.imagePath != null && widget.imagePath!.isNotEmpty) {
      return Image.file(File(widget.imagePath!), fit: BoxFit.contain);
    }
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      return Image.network(widget.imageUrl!, fit: BoxFit.contain);
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: _bgColor,
        foregroundColor: _bgColor == Colors.black
          ? Colors.white : Colors.black,
        title: Text(widget.title,
          style: TextStyle(
            color: _bgColor == const Color(0xFF1C1C1E) ||
                   _bgColor == const Color(0xFF1B5E20) ||
                   _bgColor == const Color(0xFF0D47A1) ||
                   _bgColor == const Color(0xFF880E4F)
              ? Colors.white : Colors.black,
            fontSize: 14)),
        actions: [
          IconButton(
            icon: Icon(Icons.download_outlined,
              color: _bgColor == const Color(0xFF1C1C1E) ||
                     _bgColor == const Color(0xFF1B5E20) ||
                     _bgColor == const Color(0xFF0D47A1) ||
                     _bgColor == const Color(0xFF880E4F)
                ? Colors.white : Colors.black),
            onPressed: () {
              widget.onSave();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Center(child: _buildImage()),
            ),
          ),
          // Color picker at bottom
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Choose background',
                  style: TextStyle(fontSize: 12, color: Color(0xFF8E8E93))),
                const SizedBox(height: 10),
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.colors.length,
                    itemBuilder: (ctx, i) {
                      final color = widget.colors[i];
                      final selected = _bgColor == color;
                      return GestureDetector(
                        onTap: () => setState(() => _bgColor = color),
                        child: Container(
                          width: 40, height: 40,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected
                                ? const Color(0xFF1B5E20)
                                : const Color(0xFFE5E5EA),
                              width: selected ? 3 : 1),
                          ),
                          child: selected
                            ? const Icon(Icons.check, size: 18,
                                color: Color(0xFF1B5E20))
                            : null,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      widget.onSave();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.download_outlined),
                    label: const Text('Save to Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14))),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
