import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../app_state.dart';

const _baseR = 'https://smart-tailor-backend-mi4z.onrender.com';

class ReviewsScreen extends StatefulWidget {
  final int tailorId;
  final String tailorName;
  const ReviewsScreen({super.key, required this.tailorId, required this.tailorName});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  Map? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    try {
      final res = await http.get(
        Uri.parse('$_baseR/api/reviews/tailor/${widget.tailorId}'));
      if (!mounted) return;
      setState(() { _data = jsonDecode(res.body); _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviews = _data?['reviews'] as List? ?? [];
    final avg = _data?['average'] ?? 0;
    final total = _data?['total'] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: Text('${widget.tailorName} Reviews'),
        backgroundColor: const Color(0xFFF2F2F7),
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF1B5E20)))
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Rating summary
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    Column(children: [
                      Text('$avg',
                        style: const TextStyle(fontSize: 48,
                          fontWeight: FontWeight.w700, color: Color(0xFF1C1C1E))),
                      _starRow(avg.toDouble(), size: 20),
                      const SizedBox(height: 4),
                      Text('$total reviews',
                        style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 13)),
                    ]),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        children: [5, 4, 3, 2, 1].map((star) {
                          final count = reviews.where((r) => r['rating'] == star).length;
                          final pct = total > 0 ? count / total : 0.0;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(children: [
                              Text('$star', style: const TextStyle(
                                fontSize: 12, color: Color(0xFF8E8E93))),
                              const SizedBox(width: 6),
                              const Icon(Icons.star, size: 12, color: Colors.amber),
                              const SizedBox(width: 6),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: pct.toDouble(),
                                    backgroundColor: const Color(0xFFE5E5EA),
                                    color: Colors.amber,
                                    minHeight: 6,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text('$count', style: const TextStyle(
                                fontSize: 12, color: Color(0xFF8E8E93))),
                            ]),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Reviews list
              if (reviews.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text('No reviews yet',
                      style: TextStyle(color: Color(0xFF8E8E93), fontSize: 15)),
                  ))
              else
                ...reviews.map((r) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xFF1B5E20),
                          radius: 18,
                          backgroundImage: (r['customer_avatar'] ?? '').isNotEmpty
                            ? NetworkImage(r['customer_avatar']) : null,
                          child: (r['customer_avatar'] ?? '').isEmpty
                            ? Text((r['customer_name'] ?? 'C')[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white,
                                  fontWeight: FontWeight.bold))
                            : null,
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r['customer_name'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.w600,
                                fontSize: 14, color: Color(0xFF1C1C1E))),
                            _starRow((r['rating'] ?? 0).toDouble(), size: 14),
                          ],
                        )),
                        Text(
                          (r['created_at'] ?? '').toString().substring(0, 10),
                          style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 11)),
                      ]),
                      if ((r['comment'] ?? '').isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(r['comment'],
                          style: const TextStyle(color: Color(0xFF3A3A3C),
                            fontSize: 13, height: 1.5)),
                      ],
                    ],
                  ),
                )).toList(),
            ],
          ),
    );
  }

  Widget _starRow(double rating, {double size = 16}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) => Icon(
        i < rating.floor()
          ? Icons.star
          : i < rating
            ? Icons.star_half
            : Icons.star_border,
        color: Colors.amber, size: size)),
    );
  }
}

// Widget to leave a review
class LeaveReviewSheet extends StatefulWidget {
  final int orderId;
  final int tailorId;
  final int customerId;
  final String tailorName;
  final VoidCallback onSubmitted;

  const LeaveReviewSheet({
    super.key,
    required this.orderId,
    required this.tailorId,
    required this.customerId,
    required this.tailorName,
    required this.onSubmitted,
  });

  @override
  State<LeaveReviewSheet> createState() => _LeaveReviewSheetState();
}

class _LeaveReviewSheetState extends State<LeaveReviewSheet> {
  int _rating = 0;
  final _commentCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a star rating')));
      return;
    }
    setState(() => _submitting = true);
    try {
      await http.post(
        Uri.parse('$_baseR/api/reviews/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'customer_id': widget.customerId,
          'tailor_id': widget.tailorId,
          'order_id': widget.orderId,
          'rating': _rating,
          'comment': _commentCtrl.text.trim(),
        }),
      );
      Navigator.pop(context);
      widget.onSubmitted();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted! Thank you ⭐'),
          backgroundColor: Color(0xFF1B5E20)));
    } catch (e) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rate ${widget.tailorName}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
              color: Color(0xFF1C1C1E))),
          const SizedBox(height: 4),
          const Text('How was your experience?',
            style: TextStyle(color: Color(0xFF8E8E93), fontSize: 13)),
          const SizedBox(height: 20),

          // Star selector
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (i) => GestureDetector(
                onTap: () => setState(() => _rating = i + 1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    i < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber, size: 40),
                ),
              )),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              _rating == 0 ? 'Tap to rate'
                : _rating == 1 ? 'Poor'
                : _rating == 2 ? 'Fair'
                : _rating == 3 ? 'Good'
                : _rating == 4 ? 'Very Good'
                : 'Excellent!',
              style: TextStyle(
                color: _rating == 0
                  ? const Color(0xFF8E8E93)
                  : Colors.amber.shade700,
                fontWeight: FontWeight.w600, fontSize: 14)),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Comment (optional)',
              hintText: 'Tell others about your experience...',
              prefixIcon: Icon(Icons.comment_outlined, color: Color(0xFF1B5E20))),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
                : const Text('Submit Review'),
            ),
          ),
        ],
      ),
    );
  }
}
