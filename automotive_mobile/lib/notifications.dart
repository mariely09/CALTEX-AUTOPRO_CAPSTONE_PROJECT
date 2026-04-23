import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationRole { admin, staff, customer }

class AppNotifications extends StatefulWidget {
  final NotificationRole role;
  const AppNotifications({super.key, required this.role});

  @override
  State<AppNotifications> createState() => _AppNotificationsState();
}

class _AppNotificationsState extends State<AppNotifications> {
  static const _red  = Color(0xFFE8001C);
  static const _blue = Color(0xFF003087);

  String get _roleString {
    switch (widget.role) {
      case NotificationRole.admin:    return 'admin';
      case NotificationRole.staff:    return 'staff';
      case NotificationRole.customer: return 'customer';
    }
  }

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  /// Stream: notifications where targetRole matches OR targetUid matches current user
  Stream<QuerySnapshot> get _stream {
    final uid = _uid;
    // Role-wide notifications
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('targetRole', isEqualTo: _roleString)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Personal notifications for this specific user
  Stream<QuerySnapshot> get _personalStream {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('targetUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> _markRead(String docId) async {
    final uid = _uid;
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(docId)
        .update({'readBy.$uid': true});
  }

  Future<void> _markAllRead(List<QueryDocumentSnapshot> docs) async {
    final uid = _uid;
    if (uid == null) return;
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in docs) {
      batch.update(doc.reference, {'readBy.$uid': true});
    }
    await batch.commit();
  }

  bool _isUnread(Map<String, dynamic> data) {
    final uid = _uid;
    if (uid == null) return false;
    final readBy = data['readBy'] as Map<String, dynamic>? ?? {};
    return readBy[uid] != true;
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

  String _timeAgo(Timestamp? ts) {
    if (ts == null) return '';
    final diff = DateTime.now().difference(ts.toDate());
    if (diff.inSeconds < 60)  return 'Just now';
    if (diff.inMinutes < 60)  return '${diff.inMinutes} min ago';
    if (diff.inHours < 24)    return '${diff.inHours} hr ago';
    if (diff.inDays == 1)     return 'Yesterday';
    return '${diff.inDays} days ago';
  }

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
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _stream,
        builder: (context, roleSnap) {
          return StreamBuilder<QuerySnapshot>(
            stream: _personalStream,
            builder: (context, personalSnap) {
              if (roleSnap.connectionState == ConnectionState.waiting ||
                  personalSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Merge role-wide + personal, deduplicate by doc ID
              final Map<String, QueryDocumentSnapshot> merged = {};
              for (final doc in roleSnap.data?.docs ?? []) {
                merged[doc.id] = doc;
              }
              for (final doc in personalSnap.data?.docs ?? []) {
                merged[doc.id] = doc;
              }

              // Sort by createdAt descending
              final docs = merged.values.toList()
                ..sort((a, b) {
                  final aTs = (a.data() as Map)['createdAt'] as Timestamp?;
                  final bTs = (b.data() as Map)['createdAt'] as Timestamp?;
                  if (aTs == null || bTs == null) return 0;
                  return bTs.compareTo(aTs);
                });

              final unreadCount = docs.where((d) => _isUnread(d.data() as Map<String, dynamic>)).length;

              if (docs.isEmpty) {
                return const Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.notifications_off_outlined, size: 48, color: Color(0xFFcbd5e0)),
                    SizedBox(height: 12),
                    Text('No notifications yet', style: TextStyle(color: Color(0xFF718096))),
                  ]),
                );
              }

              return Column(children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Row(children: [
                    const Icon(Icons.notifications_outlined, size: 16, color: Color(0xFF718096)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        unreadCount > 0
                          ? '$unreadCount unread notification${unreadCount > 1 ? 's' : ''}'
                          : 'All caught up!',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF718096)),
                      ),
                    ),
                    if (unreadCount > 0)
                      TextButton(
                        onPressed: () => _markAllRead(docs),
                        style: TextButton.styleFrom(foregroundColor: _red),
                        child: const Text('Mark all read', style: TextStyle(fontSize: 12)),
                      ),
                  ]),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final doc  = docs[i];
                      final data = doc.data() as Map<String, dynamic>;
                      final type    = data['type'] as String? ?? 'info';
                      final color   = _typeColor(type);
                      final isUnread = _isUnread(data);
                      final ts = data['createdAt'] as Timestamp?;

                      return GestureDetector(
                        onTap: () => _markRead(doc.id),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isUnread ? color.withOpacity(0.04) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: isUnread ? Border.all(color: color.withOpacity(0.2)) : null,
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                          ),
                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10)),
                              child: Icon(_typeIcon(type), color: color, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Expanded(
                                  child: Text(data['title'] as String? ?? '',
                                    style: TextStyle(
                                      fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                                      fontSize: 13, color: const Color(0xFF1a202c))),
                                ),
                                Text(_timeAgo(ts),
                                  style: const TextStyle(fontSize: 10, color: Color(0xFF718096))),
                              ]),
                              const SizedBox(height: 3),
                              Text(data['message'] as String? ?? '',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF4a5568))),
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
              ]);
            },
          );
        },
      ),
    );
  }
}
