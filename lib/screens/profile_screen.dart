import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppState>(context).currentUser;
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 48,
                backgroundColor: const Color(0xFF1B5E20),
                child: Text(
                  (user?['name'] ?? 'U')[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white,
                    fontSize: 36, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              Text(user?['name'] ?? '',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                  color: Color(0xFF1C1C1E), letterSpacing: -0.5)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  (user?['role'] ?? 'customer').toUpperCase(),
                  style: const TextStyle(color: Color(0xFF1B5E20),
                    fontSize: 12, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 8),
              Text(user?['email'] ?? '',
                style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 14)),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _InfoRow(icon: Icons.phone_outlined,
                      label: 'Phone', value: user?['phone'] ?? 'Not set'),
                    const Divider(height: 1, indent: 56),
                    if ((user?['role'] ?? '') == 'tailor') ...[
                      _InfoRow(icon: Icons.location_on_outlined,
                        label: 'Location', value: user?['location'] ?? 'Not set'),
                      const Divider(height: 1, indent: 56),
                      _InfoRow(icon: Icons.workspace_premium_outlined,
                        label: 'Experience',
                        value: ' years'),
                      const Divider(height: 1, indent: 56),
                      _InfoRow(icon: Icons.chat_outlined,
                        label: 'Contact', value: user?['contact_info'] ?? 'Not set'),
                      const Divider(height: 1, indent: 56),
                    ],
                    _InfoRow(icon: Icons.favorite_outline,
                      label: 'Preferences',
                      value: (user?['dress_preferences'] ?? '').isEmpty
                        ? 'None set' : user!['dress_preferences']),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
                  ),
                  onPressed: () {
                    Provider.of<AppState>(context, listen: false).clearUser();
                    Navigator.pushAndRemoveUntil(context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false);
                  },
                  child: const Text('Sign Out'),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF1B5E20), size: 22),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 12)),
              Text(value, style: const TextStyle(color: Color(0xFF1C1C1E),
                fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
