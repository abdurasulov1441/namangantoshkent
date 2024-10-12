import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:namangantoshkent/screens/home_screen.dart';

class FirebaseStream extends StatefulWidget {
  const FirebaseStream({super.key});

  @override
  _FirebaseStreamState createState() => _FirebaseStreamState();
}

class _FirebaseStreamState extends State<FirebaseStream> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeLocalNotifications();
    _initializeFirebaseMessaging();
  }

  void _initializeLocalNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Показ уведомления с изображением
  Future<void> _showNotificationWithImage(
      RemoteNotification notification) async {
    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(
      const DrawableResourceAndroidBitmap(
          'assets/icons/orders.svg'), // Замените на имя вашего изображения в `drawable` папке
      largeIcon: const DrawableResourceAndroidBitmap(
          '@mipmap/ic_launcher'), // Значок в левом углу
      contentTitle: notification.title,
      summaryText: notification.body,
    );

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      styleInformation: bigPictureStyleInformation,
      importance: Importance.high,
      priority: Priority.high,
    );

    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      platformChannelSpecifics,
    );
  }

  void _initializeFirebaseMessaging() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        if (notification != null) {
          print('Заголовок: ${notification.title}');
          print('Тело сообщения: ${notification.body}');
          _showNotificationWithImage(
              notification); // Показ уведомления с изображением
        }
      });
    } else {
      print('Пользователь не предоставил разрешение');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
              body: Center(child: Text('Что-то пошло не так!')));
        } else if (snapshot.hasData) {
          return const HomeScreen();
        } else {
          return const HomeScreen();
        }
      },
    );
  }
}
