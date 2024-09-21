// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:uni_ad_portal/main.dart';

// class FirebaseService {
//   final _firebaseMessaging = FirebaseMessaging.instance;

//   Future<void> initNotification() async {
//     await _firebaseMessaging.requestPermission();

//     final FCMToken = await _firebaseMessaging.getToken();

//     print('Token: $FCMToken');
//     initPushNotification();
//   }

//   void handleMessage(RemoteMessage? message) {
//     if (message == null) {
//       return;
//     }
//     navigationKey.currentState?.pushNamed(
//       '/notification_screen',
//       arguments: message,
//     );
//   }

//   Future initPushNotification() async {
//     FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

//     FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
//   }
// }
