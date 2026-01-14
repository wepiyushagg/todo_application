
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:todo/domain/constant/appcolors.dart';
import 'package:todo/repository/screens/splash/splashscreen.dart';
import 'package:event_logger/event_logger.dart';


final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // FirebaseMsg is now the single source of truth for all notification initialization.
  await FirebaseMsg().initFCM(navigatorKey);

  // The call to EventLoggerService().init() has been removed.

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'To-Do app',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        scaffoldBackgroundColor: AppColors.scaffoldBackground,
        useMaterial3: false,
      ),
      home: const Splashscreen(),
      routes: {
        '/event-list': (context) => const EventListScreen(),
      },
    );
  }
}
