import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                const CircleAvatar(radius: 45, backgroundColor: AppColors.primaryLight, child: Icon(Icons.person, size: 50, color: Colors.white)),
                const SizedBox(height: 12),
                Text(user?.name ?? 'Guest User', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(user?.email ?? '', style: const TextStyle(color: AppColors.textGrey)),
              ],
            ),
          ),
          const SizedBox(height: 30),
          _menuTile(Icons.edit, 'Edit Profile', () {}),
          _menuTile(Icons.restaurant_menu, 'Dietary Preferences', () {}),
          _menuTile(Icons.favorite_border, 'My Favorites', () {}),
          _menuTile(Icons.shopping_cart_outlined, 'Shopping List', () {}),
          _menuTile(Icons.notifications_none, 'Notifications', () {}),
          _menuTile(Icons.help_outline, 'Help & Support', () {}),
          const SizedBox(height: 10),
          _menuTile(Icons.logout, 'Logout', () async {
            await auth.logout();
            if (context.mounted) {
              Navigator.pushAndRemoveUntil(
                  context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
            }
          }, color: AppColors.danger),
        ],
      ),
    );
  }

  Widget _menuTile(IconData icon, String title, VoidCallback onTap, {Color? color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(icon, color: color ?? AppColors.primary),
        title: Text(title, style: TextStyle(color: color ?? AppColors.textDark)),
        trailing: color == null ? const Icon(Icons.chevron_right, color: AppColors.textGrey) : null,
        onTap: onTap,
      ),
    );
  }
}
