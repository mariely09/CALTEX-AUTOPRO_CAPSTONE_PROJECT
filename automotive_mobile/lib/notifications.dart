import 'package:flutter/material.dart';

enum NotificationRole { admin, staff, customer }

class AppNotifications extends StatefulWidget {
  final NotificationRole role;
  const AppNotifications({super.key, required this.role});

  @override
  State<AppNotifications> createState() => _AppNotificationsState();
}

class _AppNotificationsState extends State<AppNotifications> {
  static const _red = Color(0xFFE8001C);
  static const _blue = Color(0xFF003087);

  late final List<Map<String, dynamic>> _notifications;

  @override
  void initState() {
    super.initState();
    switch (widget.role) {
      case NotificationRole.admin:
        _notifications = [
          {'id': 1, 'type': 'warning', 'title': 'PMS Overdue', 'message': '2 vehicles have overdue maintenance schedules.', 'time': '2 mins ago', 'read': false},
          {'id': 2, 'type': 'warning', 'title': 'Low Stock Alert', 'message': 'Oil Filter and Air Filter are critically low.', 'time': '15 mins ago', 'read': false},
          {'id': 3, 'type': 'info', 'title': 'Service Completed', 'message': 'SVC-001 for ABC-1234 has been marked as completed.', 'time': '1 hour ago', 'read': false},
          {'id': 4, 'type': 'info', 'title': 'New User Registered', 'message': 'A new customer account has been created.', 'time': '3 hours ago', 'read': true},
          {'id': 5, 'type': 'success', 'title': 'Stock Received', 'message': 'Engine Oil 10W-40 — 20 L received from delivery.', 'time': 'Yesterday', 'read': true},
          {'id': 6, 'type': 'warning', 'title': 'PMS Due Soon', 'message': 'XYZ-5678 Toyota Hilux is due for PMS in 3 days.', 'time': 'Yesterday', 'read': true},
        ];
        break;
      case NotificationRole.staff:
        _notifications = [
          {'id': 1, 'type': 'warning', 'title': 'Low Stock Alert', 'message': 'Oil Filter and Air Filter are critically low.', 'time': '15 mins ago', 'read': false},
          {'id': 2, 'type': 'info', 'title': 'Service Assigned', 'message': 'SVC-004 for DEF-9012 has been assigned to you.', 'time': '1 hour ago', 'read': false},
          {'id': 3, 'type': 'success', 'title': 'Stock Received', 'message': 'Engine Oil 10W-40 — 20 L received from delivery.', 'time': '3 hours ago', 'read': false},
          {'id': 4, 'type': 'info', 'title': 'Service Completed', 'message': 'SVC-001 for ABC-1234 has been marked as completed.', 'time': 'Yesterday', 'read': true},
          {'id': 5, 'type': 'warning', 'title': 'PMS Due Soon', 'message': 'XYZ-5678 Toyota Hilux is due for PMS in 3 days.', 'time': 'Yesterday', 'read': true},
        ];
        break;
      case NotificationRole.customer:
        _notifications = [
          {'id': 1, 'type': 'warning', 'title': 'PMS Overdue', 'message': 'DEF-9012 Mitsubishi L300 is overdue for PMS.', 'time': '1 hr ago', 'read': false},
          {'id': 2, 'type': 'success', 'title': 'Service Complete', 'message': 'ABC-1234 oil change has been completed.', 'time': '3 hrs ago', 'read': false},
          {'id': 3, 'type': 'warning', 'title': 'PMS Due Soon', 'message': 'ABC-1234 Isuzu Truck is due for PMS in 2 months.', 'time': 'Yesterday', 'read': true},
        ];
        break;
    }
  }

  Color _typeColor(String type) {
    if (type == 'warning') return Colors.orange;
    if (type == 'success') return const Color(0xFF2c7a7b);
    return _blue;
  }

  IconData _typeIcon(String type) {
    if (type == 'warning') return Icons.warning_amber_outlined;
    if (type == 'success') return Icons.check_circle_outline;
    return Icons.info_outline;
  }

  int get _unreadCount => _notifications.where((n) => n['read'] == false).length;

  void _markAllRead() => setState(() {
    for (final n in _notifications) n['read'] = true;
  });

  void _markRead(int id) => setState(() {
    _notifications.firstWhere((n) => n['id'] == id)['read'] = true;
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: _red,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Notifications',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Mark all read', style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Row(children: [
            const Icon(Icons.notifications_outlined, size: 16, color: Color(0xFF718096)),
            const SizedBox(width: 6),
            Text(
              _unreadCount > 0
                ? '$_unreadCount unread notification${_unreadCount > 1 ? 's' : ''}'
                : 'All caught up!',
              style: const TextStyle(fontSize: 12, color: Color(0xFF718096)),
            ),
          ]),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final n = _notifications[i];
              final color = _typeColor(n['type']);
              final isUnread = n['read'] == false;
              return GestureDetector(
                onTap: () => _markRead(n['id']),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isUnread ? color.withOpacity(0.04) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: isUnread ? Border.all(color: color.withOpacity(0.2)) : null,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                  ),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(width: 40, height: 40,
                      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Icon(_typeIcon(n['type']), color: color, size: 20)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(n['title'], style: TextStyle(
                          fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                          fontSize: 13, color: const Color(0xFF1a202c))),
                        Text(n['time'], style: const TextStyle(fontSize: 10, color: Color(0xFF718096))),
                      ]),
                      const SizedBox(height: 3),
                      Text(n['message'], style: const TextStyle(fontSize: 12, color: Color(0xFF4a5568))),
                    ])),
                    if (isUnread) ...[
                      const SizedBox(width: 8),
                      Container(width: 8, height: 8,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                    ],
                  ]),
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}
