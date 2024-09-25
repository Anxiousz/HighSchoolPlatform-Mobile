import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final DatabaseReference ref;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  NotificationService({required String userId})
      : ref =
            FirebaseDatabase.instance.ref().child('notification').child(userId),
        flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin() {
    // Initialize the notification plugin for Android and iOS
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // App icon
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Fetch notifications from Firebase
  Future<List<Map<String, dynamic>>> fetchNotifications() async {
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
      return fetchedNotifications;
    } else {
      print('No notifications found');
      return [];
    }
  }

  // Listen for real-time notification updates
  void listenForNewNotifications(
      Function(Map<String, dynamic>) onNewNotification) {
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

        // Call the function to show notification
        _showNotification(
            newNotification['content'], newNotification['sender']);

        onNewNotification(newNotification);
      }
    });
  }

  // Show a local notification
  Future<void> _showNotification(String? title, String? body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel', // Channel ID
      'High Importance Notifications', // Channel name
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      title ?? 'New Notification', // Notification title
      body ?? 'You have a new message', // Notification body
      platformChannelSpecifics,
    );
  }
}
