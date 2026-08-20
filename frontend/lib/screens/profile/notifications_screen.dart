import 'package:flutter/material.dart';
import '../../core/theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  // Placeholder — replace with GET /notifications results
  final List<Map<String, String>> notifications = const [
    {'title': 'New recipe matches your ingredients!', 'time': '2h ago'},
    {'title': 'Your recipe "Chicken Curry" got a new review', 'time': '1d ago'},
    {'title': 'Weekly meal plan is ready', 'time': '3d ago'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: notifications.isEmpty
          ? const Center(child: Text('No notifications yet', style: TextStyle(color: AppColors.textGrey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, i) {
                final n = notifications[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                  child: Row(
                    children: [
                      const CircleAvatar(backgroundColor: AppColors.primaryLight, child: Icon(Icons.notifications, color: AppColors.primary, size: 18)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(n['title']!, style: const TextStyle(fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Text(n['time']!, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
