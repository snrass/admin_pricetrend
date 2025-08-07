import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';
import 'screens/auth_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/analytics_screen.dart'; // Import AnalyticsScreen
import 'controllers/auth_controller.dart';
import 'middleware/auth_middleware.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Get.put(AuthController()); // Initialize AuthController
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Admin PriceTrend',
      theme: AppTheme.theme,
      initialRoute: '/auth',
      getPages: [
        GetPage(
          name: '/auth',
          page: () => AuthScreen(),
          middlewares: [
            AuthMiddleware(),
          ],
        ),
        GetPage(
          name: '/dashboard',
          page: () => DashboardScreen(),
          middlewares: [
            AuthMiddleware(),
          ],
        ),
        GetPage(
          name: '/analytics',
          page: () => AnalyticsScreen(),
          middlewares: [
            AuthMiddleware(),
          ],
        ),
      ],
    );
  }
}
