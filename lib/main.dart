import 'dart:async';
import 'package:flutter/material.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import flutter_dotenv
import 'features/home/screens/home_screen.dart';

final unityAdsReady = ValueNotifier<bool>(false);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // ✅ Use a Completer to truly wait for Unity Ads init callback
  final completer = Completer<void>();

  UnityAds.init(
    gameId: dotenv.env['GAME_ID']!,
    testMode: false,
    onComplete: () {
      debugPrint('Unity Ads Initialized ✅');
      unityAdsReady.value = false;
      if (!completer.isCompleted) completer.complete();
    },
    onFailed: (error, message) {
      debugPrint('Unity Ads Init Failed: $error $message');
      if (!completer.isCompleted) completer.complete(); // don't hang the app
    },
  );

  // ✅ Actually wait for the callback before starting the app
  await completer.future.timeout(
    const Duration(seconds: 10),
    onTimeout: () {
      debugPrint('Unity Ads init timed out, continuing anyway');
    },
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomeScreen());
  }
}
