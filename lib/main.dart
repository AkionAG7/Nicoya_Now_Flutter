import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nicoya_now/app/features/driver/presentation/controllers/driver_controller.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nicoya_now/app/core/di/service_locator.dart';
import 'package:nicoya_now/app/core/services/notification_service.dart';
import 'package:nicoya_now/app/core/widgets/notification_initializer.dart';
import 'package:nicoya_now/app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:nicoya_now/app/features/merchant/presentation/controllers/merchant_registration_controller.dart';
import 'package:nicoya_now/app/features/admin/presentation/controllers/admin_merchant_controller.dart';
import 'package:nicoya_now/app/interface/Navigators/app_routes.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';
import 'package:nicoya_now/app/interface/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  setupServiceLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => locator<AuthController>()),
        ChangeNotifierProvider(
          create: (_) => locator<MerchantRegistrationController>(),
        ),
        ChangeNotifierProvider(
          create: (_) => locator<AdminMerchantController>(),
        ),
        ChangeNotifierProvider(
          create: (_) => locator<NotificationService>(),
        ),
            ChangeNotifierProvider(
          create: (_) => locator<DriverController>(),
        ),
      ],
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },        
        child: NotificationInitializer(
          child: MaterialApp(
            title: 'Nicoya Now',
            theme: AppTheme.lightTheme,
            initialRoute: Routes.appStartNavigation,
            routes: appRoutes,
          ),
        ),
      ),
    );
  }
}