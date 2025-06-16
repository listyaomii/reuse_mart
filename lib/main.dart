import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reuse_mart/View/homePage.dart';
import 'package:reuse_mart/View/informasiUmum.dart';
import 'package:reuse_mart/View/OnBoarding.dart';
// import 'package:reuse_mart/View/hunterHome.dart';
// import 'package:reuse_mart/View/kurirHome.dart';
import 'package:reuse_mart/View/pembeliHome.dart';
import 'package:reuse_mart/View/penitipHome.dart';
import 'package:reuse_mart/View/loginPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:reuse_mart/client/loginClient.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi data format tanggal untuk locale 'id' (Indonesia)
  await initializeDateFormatting('id', null);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    print('Token FCM diperbarui: $newToken');
    updateFcmTokenOnServer(newToken);
  });

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
    return FutureBuilder(
      future: Future.delayed(const Duration(seconds: 3)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Informasiumum();
        } else {
          return MaterialApp(
            title: 'ReuseMart',
            initialRoute: '/',
            navigatorKey: navigatorKey,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('id'), // Bahasa Indonesia
              Locale('en'), // English
            ],

            // Routes sederhana untuk pembeli dan penitip saja
            routes: {
              '/': (context) => const OnBoarding(),
              '/login': (context) => const LoginPage(),
              '/pembeli_dashboard': (context) => const Pembelihome(),
              '/home': (context) => const HomePage(),
            },

            // Handle route dengan parameter untuk penitip
            onGenerateRoute: (settings) {
              print('Generating route for: ${settings.name}');
              print('Arguments: ${settings.arguments}');

              switch (settings.name) {
                case '/login':
                  return MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                    settings: settings,
                  );

                case '/penitip_home':
                  // Extract token dari arguments untuk penitip
                  final args = settings.arguments as Map<String, dynamic>?;
                  final token = args?['token'] as String?;

                  print(
                      'Penitip route - Token: ${token?.substring(0, 20) ?? 'null'}...');

                  return MaterialPageRoute(
                    builder: (context) => SellerProfilePage(token: token),
                    settings: settings,
                  );

                // Comment route untuk hunter dan kurir sementara
                /*
                case '/hunter_home':
                  final args = settings.arguments as Map<String, dynamic>?;
                  final token = args?['token'] as String?;
                  
                  return MaterialPageRoute(
                    builder: (context) => HunterProfilePage(token: token ?? ''),
                    settings: settings,
                  );
                  
                case '/kurir_home':
                  final args = settings.arguments as Map<String, dynamic>?;
                  final token = args?['token'] as String?;
                  
                  return MaterialPageRoute(
                    builder: (context) => CourierProfilePage(token: token ?? ''),
                    settings: settings,
                  );
                */

                case '/pembeli_dashboard':
                  return MaterialPageRoute(
                    builder: (context) => const Pembelihome(),
                    settings: settings,
                  );

                case '/home':
                  return MaterialPageRoute(
                    builder: (context) => const HomePage(),
                    settings: settings,
                  );

                case '/onboarding':
                  return MaterialPageRoute(
                    builder: (context) => const OnBoarding(),
                    settings: settings,
                  );

                default:
                  // Fallback untuk route yang tidak dikenal
                  print(
                      'Unknown route: ${settings.name}, redirecting to login');
                  return MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                    settings: RouteSettings(name: '/login'),
                  );
              }
            },

            // Fallback terakhir untuk route tidak dikenal
            onUnknownRoute: (settings) {
              print('Unknown route fallback: ${settings.name}');
              return MaterialPageRoute(
                builder: (context) => const LoginPage(),
                settings: const RouteSettings(name: '/login'),
              );
            },

            // Theme untuk konsistensi UI
            theme: ThemeData(
              primarySwatch: Colors.green,
              primaryColor: const Color(0xFF354024),
              fontFamily: 'Roboto',
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),

            debugShowCheckedModeBanner: false,
          );
        }
      },
    );
  }
}
