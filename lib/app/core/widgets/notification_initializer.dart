import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nicoya_now/app/core/services/notification_service.dart';

class NotificationInitializer extends StatefulWidget {
  final Widget child;

  const NotificationInitializer({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<NotificationInitializer> createState() => _NotificationInitializerState();
}

class _NotificationInitializerState extends State<NotificationInitializer> {
  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _listenToAuthChanges();
  }

  void _initializeNotifications() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationService = Provider.of<NotificationService>(context, listen: false);
      
      if (Supabase.instance.client.auth.currentUser != null) {
        notificationService.initialize();
      }
    });
  }

  void _listenToAuthChanges() {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      final user = data.session?.user;

      if (mounted) {
        final notificationService = Provider.of<NotificationService>(context, listen: false);

        if (event == AuthChangeEvent.signedIn && user != null) {
          // Usuario se logeó - inicializar notificaciones
          notificationService.reinitializeForUser();
        } else if (event == AuthChangeEvent.signedOut) {
          // Usuario se deslogeó - limpiar notificaciones
          notificationService.dispose();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
