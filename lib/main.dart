import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reuse_mart/View/homePage.dart';
import 'package:reuse_mart/View/hunterHome.dart';
import 'package:reuse_mart/View/kurirHome.dart';
import 'package:reuse_mart/View/pembeliHome.dart';
import 'package:reuse_mart/View/penitipHome.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:reuse_mart/client/loginClient.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    print('Token FCM diperbarui: $newToken');
    updateFcmTokenOnServer(newToken);
  });

  await initializeDateFormatting('id_ID', null);
  runApp(const ProviderScope(child: MainApp()));
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print('Handling background message: ${message.messageId}');
}

Future<void> updateFcmTokenOnServer(String newToken) async {
  try {
    final authService = AuthService();
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    if (authToken != null) {
      await authService.updateFcmToken(authToken, newToken);
      print('Token FCM berhasil diperbarui di server');
    } else {
      print('Token autentikasi tidak ditemukan');
    }
  } catch (e) {
    print('Gagal memperbarui token di server: $e');
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Reusemart',
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/pembeli_dashboard': (context) => const Pembelihome(),
      },
    );
  }
}
