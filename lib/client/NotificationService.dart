import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  void initialize(BuildContext context) {
    // Request permission
    _messaging
        .requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    )
        .then((settings) {
      print('Notification permission status: ${settings.authorizationStatus}');
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received foreground message: ${message.messageId}');
      if (message.notification != null) {
        _showNotificationDialog(
          context,
          message.notification!.title ?? 'Notification',
          message.notification!.body ?? '',
          message.data,
        );
      }
    });

    // Handle message opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message opened from background: ${message.messageId}');
      _handleNotificationNavigation(context, message.data);
    });
  }

  Future checkInitialMessage(BuildContext context) async {
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      print('App opened from terminated state: ${initialMessage.messageId}');
      _handleNotificationNavigation(context, initialMessage.data);
    }
  }

  void _showNotificationDialog(
    BuildContext context,
    String title,
    String body,
    Map data,
  ) {
    if (!context.mounted) {
      print('Context not mounted, cannot show dialog');
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleNotificationNavigation(context, data);
            },
            child: const Text('View'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }

  void _handleNotificationNavigation(BuildContext context, Map data) {
    print('Navigating with data: $data');
    if (!context.mounted) {
      print('Context not mounted, cannot navigate');
      return;
    }
    if (data.containsKey('transaksi_id')) {
      Navigator.pushNamed(context, '/pembeli_dashboard', arguments: {
        'tab': 'transactions',
        'transaksi_id': data['transaksi_id'],
      });
    } else if (data.containsKey('barang_id')) {
      Navigator.pushNamed(context, '/pembeli_dashboard', arguments: {
        'tab': 'products',
        'barang_id': data['barang_id'],
      });
    } else {
      print('No actionable data in notification');
    }
  }
}
