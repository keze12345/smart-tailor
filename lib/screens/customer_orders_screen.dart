import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../app_state.dart';
import 'reviews_screen.dart';

const _baseO = 'https://smart-tailor-backend-mi4z.onrender.com';

class CustomerOrdersScreen extends StatefulWidget {
  const CustomerOrdersScreen({super.key});
  @override
  State<CustomerOrdersScreen> createState() => _CustomerOrdersScreenState();
}

class _CustomerOrdersScreenState extends State<CustomerOrdersScreen> {
  List _orders = [];
  bool _loading = true;
  final Map<int, Map?> _reviews = {};

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final userId = Provider.of<AppState>(context, listen: false).userId;
    try {
      final res = await http.get(
        Uri.parse('$_baseO/api/orders/customer/$userId'));
      if (!mounted) return;
      final orders = List.from(jsonDecode(res.body));
      setState(() { _orders = orders; _loading = false; });
      // Fetch reviews for completed orders
      for (final o in orders) {
        if (o['status'] == 'completed') {
          _fetchOrderReview(o['id']);
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _fetchOrderReview(int orderId) async {
    try {
      final res = await http.get(
        Uri.parse('$_baseO/api/reviews/order/$orderId'));
      if (!mounted) return;
      final data = jsonDecode(res.body);
      setState(() => _reviews[orderId] = data);
    } catch (e) {}
  }

  void _showReviewSheet(Map order) {
    final appState = Provider.of<AppState>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => LeaveReviewSheet(
        orderId: order['id'],
        tailorId: order['tailor_id'],
        customerId: appState.userId,
        tailorName: order['tailor_name'] ?? 'Tailor',
        onSubmitted: () => _fetchOrderReview(order['id']),
      ),
    );
  }

  Widget _statusBadge(String? status) {
    Color bg, fg;
    switch (status) {
      case 'accepted': bg = const Color(0xFFE3F2FD); fg = Colors.blue; break;
      case 'completed': bg = const Color(0xFFE8F5E9); fg = const Color(0xFF1B5E20); break;
      case 'cancelled': bg = const Color(0xFFFFEBEE); fg = Colors.red; break;
      default: bg = const Color(0xFFFFF3E0); fg = Colors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status ?? 'pending',
        style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: const Color(0xFFF2F2F7),
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF1B5E20)))
        : _orders.isEmpty
          ? Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
                Icon(Icons.shopping_bag_outlined, size: 60, color: Color(0xFFE5E5EA)),
                SizedBox(height: 16),
                Text('No orders yet',
                  style: TextStyle(color: Color(0xFF8E8E93), fontSize: 16)),
              ]))
          : RefreshIndicator(
              onRefresh: _fetchOrders,
              color: const Color(0xFF1B5E20),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _orders.length,
                itemBuilder: (ctx, i) {
                  final order = _orders[i];
                  final orderId = order['id'] as int;
                  final isCompleted = order['status'] == 'completed';
                  final review = _reviews[orderId];
                  final hasReview = review != null;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(order['post_title'] ?? '',
                                style: const TextStyle(fontWeight: FontWeight.w600,
                                  fontSize: 15, color: Color(0xFF1C1C1E))),
                              Text('by ${order['tailor_name'] ?? ''}',
                                style: const TextStyle(
                                  color: Color(0xFF8E8E93), fontSize: 13)),
                            ],
                          )),
                          _statusBadge(order['status']),
                        ]),
                        const SizedBox(height: 10),
                        Row(children: [
                          if ((order['budget'] ?? 0) > 0) ...[
                            const Icon(Icons.payments_outlined,
                              size: 13, color: Color(0xFF8E8E93)),
                            const SizedBox(width: 4),
                            Text('Budget: ${order['budget']?.toStringAsFixed(0)} FCFA',
                              style: const TextStyle(
                                color: Color(0xFF8E8E93), fontSize: 12)),
                            const SizedBox(width: 12),
                          ],
                          const Icon(Icons.calendar_today_outlined,
                            size: 13, color: Color(0xFF8E8E93)),
                          const SizedBox(width: 4),
                          Text(order['created_at'].toString().substring(0, 10),
                            style: const TextStyle(
                              color: Color(0xFF8E8E93), fontSize: 12)),
                        ]),

                        // Review section for completed orders
                        if (isCompleted) ...[
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          if (hasReview) ...[
                            Row(children: [
                              ...List.generate(5, (s) => Icon(
                                s < (review!['rating'] ?? 0)
                                  ? Icons.star : Icons.star_border,
                                color: Colors.amber, size: 16)),
                              const SizedBox(width: 8),
                              const Text('Your review',
                                style: TextStyle(color: Color(0xFF8E8E93),
                                  fontSize: 12)),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => _showReviewSheet(order),
                                child: const Text('Edit',
                                  style: TextStyle(color: Color(0xFF1B5E20),
                                    fontSize: 12, fontWeight: FontWeight.w600)),
                              ),
                            ]),
                            if ((review!['comment'] ?? '').isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(review['comment'],
                                style: const TextStyle(
                                  color: Color(0xFF3A3A3C), fontSize: 13)),
                            ],
                          ] else ...[
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => _showReviewSheet(order),
                                icon: const Icon(Icons.star_outline,
                                  color: Colors.amber, size: 18),
                                label: const Text('Leave a Review',
                                  style: TextStyle(color: Color(0xFF1B5E20))),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFF1B5E20)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                              ),
                            ),
                          ],
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }
}
