import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class NotificationListScreen extends StatefulWidget {
  final String userId; // User ID to fetch notifications

  const NotificationListScreen({Key? key, required this.userId})
      : super(key: key);

  @override
  _NotificationListScreenState createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  List<Map<String, dynamic>> notifications = []; // Notifications list
  late DatabaseReference ref; // Reference to the Firebase database

  @override
  void initState() {
    super.initState();
    // Initialize Firebase reference
    ref = FirebaseDatabase.instance
        .ref()
        .child('notification')
        .child(widget.userId);
    // Fetch existing notifications and listen for real-time updates
    fetchAndListenForNotifications();
  }

  @override
  void dispose() {
    // Stop listening when the widget is disposed
    ref.onChildAdded.drain();
    super.dispose();
  }

  // Format the timestamp
  String formatTimestamp(int timestamp) {
    // Check if the timestamp is in seconds (10 digits) or milliseconds (13 digits)
    if (timestamp.toString().length == 10) {
      // Convert from seconds to DateTime and localize
      DateTime dateTime =
          DateTime.fromMillisecondsSinceEpoch(timestamp * 1000).toLocal();
      return DateFormat('dd/MM/yyyy HH:mm:ss').format(dateTime);
    } else if (timestamp.toString().length == 13) {
      // Already in milliseconds
      DateTime dateTime =
          DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();
      return DateFormat('dd/MM/yyyy HH:mm:ss').format(dateTime);
    } else {
      return "Invalid timestamp";
    }
  }

  // Fetch notifications and listen for real-time updates
  void fetchAndListenForNotifications() {
    // Fetch existing notifications
    fetchNotifications();
    // Listen for new notifications added in real-time
    listenForNewNotifications();
  }

  // Fetch existing notifications from Firebase
  Future<void> fetchNotifications() async {
    final snapshot = await ref.get();

    if (snapshot.exists) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

      List<Map<String, dynamic>> fetchedNotifications = [];
      data.forEach((key, value) {
        fetchedNotifications.add({
          'content': value['content'] ?? 'No content',
          'roomId': value['roomId'] ?? 'No room',
          'sender': value['sender'] ?? 'Unknown sender',
          'timestamp': value['timestamp'] ?? 0,
          'type': value['type'] ?? 'Unknown type',
        });
      });

      // Sort by timestamp (newest first)
      fetchedNotifications
          .sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

      if (mounted) {
        setState(() {
          notifications = fetchedNotifications;
        });
      }
    } else {
      print('No notifications found');
    }
  }

  // Listen for new notifications added in real-time
  void listenForNewNotifications() {
    ref.onChildAdded.listen((event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> value = event.snapshot.value as Map;
        Map<String, dynamic> newNotification = {
          'content': value['content'] ?? 'No content',
          'roomId': value['roomId'] ?? 'No room',
          'sender': value['sender'] ?? 'Unknown sender',
          'timestamp': value['timestamp'] ?? 0,
          'type': value['type'] ?? 'Unknown type',
        };

        // Add the new notification and sort by timestamp
        if (mounted) {
          setState(() {
            notifications.add(newNotification);
            notifications
                .sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách thông báo'),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text(
                'Không có thông báo nào',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                String formattedTimestamp = 'Unknown time';

                if (notification['timestamp'] != null &&
                    notification['timestamp'] is int) {
                  formattedTimestamp =
                      formatTimestamp(notification['timestamp']);
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 198, 231, 212),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification['content'] ?? 'Không có nội dung',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Người gửi: ${notification['sender'] ?? 'Không rõ'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Thời gian: $formattedTimestamp',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Loại: ${notification['type'] ?? 'Không rõ'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
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
