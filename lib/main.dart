import 'package:Mess/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static FirebaseAnalytics analytics =
      FirebaseAnalytics.instance; // Corrected initialization
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mess IIT',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
      navigatorObservers: [observer],
    );
  }
}
