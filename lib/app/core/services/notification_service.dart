import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nicoya_now/app/core/models/notification_model.dart';

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final SupabaseClient _supabase = Supabase.instance.client;
  
  List<NotificationModel> _notifications = [];
  bool _isInitialized = false;
  StreamSubscription? _notificationSubscription;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  bool get hasUnread => unreadCount > 0;

  // Inicializar el servicio
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _initializeLocalNotifications();
      await _loadNotifications();
      await _subscribeToRealtime();
      _isInitialized = true;
      debugPrint('✅ NotificationService initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing NotificationService: $e');
    }
  }

  // Configurar notificaciones locales
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Solicitar permisos en Android 13+ (skip on web)
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  // Manejar tap en notificación
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      // Aquí puedes agregar navegación basada en el payload
      debugPrint('Notification tapped with payload: $payload');
    }
  }

  // Cargar notificaciones desde Supabase
  Future<void> _loadNotifications() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(50);

      _notifications = (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();

      notifyListeners();
      debugPrint('📱 Loaded ${_notifications.length} notifications');
    } catch (e) {
      debugPrint('❌ Error loading notifications: $e');
    }
  }

  // Suscribirse a notificaciones en tiempo real
  Future<void> _subscribeToRealtime() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      _notificationSubscription = _supabase
          .from('notifications')
          .stream(primaryKey: ['id'])
          .eq('user_id', user.id)
          .listen((data) {
            _handleRealtimeUpdate(data);
          });

      debugPrint('🔄 Subscribed to realtime notifications');
    } catch (e) {
      debugPrint('❌ Error subscribing to realtime: $e');
    }
  }

  // Manejar actualizaciones en tiempo real
  void _handleRealtimeUpdate(List<Map<String, dynamic>> data) {
    try {
      final newNotifications = data
          .map((json) => NotificationModel.fromJson(json))
          .toList();

      // Verificar si hay notificaciones nuevas
      for (final notification in newNotifications) {
        final existingIndex = _notifications.indexWhere((n) => n.id == notification.id);
        
        if (existingIndex == -1) {
          // Nueva notificación
          _notifications.insert(0, notification);
          _showLocalNotification(notification);
          _playNotificationSound();
        } else {
          // Actualizar notificación existente
          _notifications[existingIndex] = notification;
        }
      }

      // Ordenar por fecha (más recientes primero)
      _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      notifyListeners();
      debugPrint('🔔 Updated notifications from realtime');
    } catch (e) {
      debugPrint('❌ Error handling realtime update: $e');
    }
  }
  // Mostrar notificación local
  Future<void> _showLocalNotification(NotificationModel notification) async {
    // Skip local notifications on web
    if (kIsWeb) {
      debugPrint('🌐 Showing web notification: ${notification.title}');
      return;
    }

    try {
      const androidDetails = AndroidNotificationDetails(
        'nicoya_now_notifications',
        'NicoyaNow Notifications',
        channelDescription: 'Notificaciones de pedidos y actualizaciones',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        notification.hashCode,
        '${notification.getIcon()} ${notification.title}',
        notification.body,
        details,
        payload: notification.id,
      );
    } catch (e) {
      debugPrint('❌ Error showing local notification: $e');
    }
  }

  // Reproducir sonido de notificación
  void _playNotificationSound() {
    try {
      SystemSound.play(SystemSoundType.alert);
      HapticFeedback.lightImpact();
    } catch (e) {
      debugPrint('❌ Error playing notification sound: $e');
    }
  }

  // Marcar notificación como leída
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);

      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        notifyListeners();
      }

      debugPrint('✅ Marked notification as read: $notificationId');
    } catch (e) {
      debugPrint('❌ Error marking notification as read: $e');
    }
  }

  // Marcar todas como leídas
  Future<void> markAllAsRead() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', user.id)
          .eq('is_read', false);

      for (int i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].isRead) {
          _notifications[i] = _notifications[i].copyWith(isRead: true);
        }
      }

      notifyListeners();
      debugPrint('✅ Marked all notifications as read');
    } catch (e) {
      debugPrint('❌ Error marking all notifications as read: $e');
    }
  }

  // Eliminar notificación
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .delete()
          .eq('id', notificationId);

      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();

      debugPrint('🗑️ Deleted notification: $notificationId');
    } catch (e) {
      debugPrint('❌ Error deleting notification: $e');
    }
  }

  // Crear notificación manual (para testing o notificaciones del sistema)
  Future<void> createNotification({
    required String title,
    required String body,
    required NotificationType type,
    String? orderId,
    String? merchantId,
    String? driverId,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('notifications').insert({
        'user_id': user.id,
        'title': title,
        'body': body,
        'type': type.value,
        'order_id': orderId,
        'merchant_id': merchantId,
        'driver_id': driverId,
      });

      debugPrint('✅ Created manual notification: $title');
    } catch (e) {
      debugPrint('❌ Error creating notification: $e');
    }
  }

  // Refrescar notificaciones
  Future<void> refresh() async {
    await _loadNotifications();
  }

  // Limpiar recursos
  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

  // Reinicializar para nuevo usuario
  Future<void> reinitializeForUser() async {
    _notifications.clear();
    await _notificationSubscription?.cancel();
    _isInitialized = false;
    await initialize();
  }

  // Obtener notificaciones por tipo
  List<NotificationModel> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  // Limpiar notificaciones antiguas (más de 30 días)
  Future<void> cleanupOldNotifications() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      await _supabase
          .from('notifications')
          .delete()
          .eq('user_id', user.id)
          .eq('is_read', true)
          .lt('created_at', thirtyDaysAgo.toIso8601String());

      await _loadNotifications();
      debugPrint('🧹 Cleaned up old notifications');
    } catch (e) {
      debugPrint('❌ Error cleaning up notifications: $e');
    }
  }
}
