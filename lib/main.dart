import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'l10n/locale.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // Portrait — phone-friendly for drivers
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  WakelockPlus.enable();

  final prefs = await SharedPreferences.getInstance();
  final driverName = prefs.getString('driver_name');
  final storeId = prefs.getString('driver_store_id');
  final driverId = prefs.getString('driver_id');

  runApp(DriverApp(
    driverName: driverName,
    storeId: storeId,
    driverId: driverId,
  ));
}

class DriverApp extends StatelessWidget {
  final String? driverName;
  final String? storeId;
  final String? driverId;

  const DriverApp({
    super.key,
    this.driverName,
    this.storeId,
    this.driverId,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLocale>(
      valueListenable: localeNotifier,
      builder: (_, __, ___) => MaterialApp(
        title: 'EazyOrder Driver',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.themeData,
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.mouse,
            PointerDeviceKind.touch,
            PointerDeviceKind.stylus,
          },
        ),
        home: PopScope(
          canPop: false,
          child: (driverName != null && storeId != null && driverId != null)
              ? HomeScreen(
                  driverName: driverName!,
                  storeId: storeId!,
                  driverId: driverId!,
                )
              : const LoginScreen(),
        ),
      ),
    );
  }
}
