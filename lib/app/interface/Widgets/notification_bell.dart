import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nicoya_now/app/core/services/notification_service.dart';
import 'package:nicoya_now/app/core/models/notification_model.dart';

class NotificationBell extends StatelessWidget {
  final double size;
  final Color? color;
  final Color? badgeColor;
  final bool showBadge;

  const NotificationBell({
    Key? key,
    this.size = 24,
    this.color,
    this.badgeColor,
    this.showBadge = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationService>(
      builder: (context, notificationService, child) {
        final unreadCount = notificationService.unreadCount;
        
        return GestureDetector(
          onTap: () => _showNotificationBottomSheet(context),
          child: Stack(
            children: [
              Icon(
                Icons.notifications_outlined,
                size: size,
                color: color ?? Theme.of(context).iconTheme.color,
              ),
              if (showBadge && unreadCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: badgeColor ?? Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showNotificationBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationBottomSheet(),
    );
  }
}

class NotificationBottomSheet extends StatefulWidget {
  const NotificationBottomSheet({Key? key}) : super(key: key);

  @override
  State<NotificationBottomSheet> createState() => _NotificationBottomSheetState();
}

class _NotificationBottomSheetState extends State<NotificationBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Notificaciones',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Consumer<NotificationService>(
                  builder: (context, notificationService, child) {
                    if (!notificationService.hasUnread) return const SizedBox();
                    
                    return TextButton(
                      onPressed: () => notificationService.markAllAsRead(),
                      child: const Text('Marcar todas como leídas'),
                    );
                  },
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Notifications list
          Expanded(
            child: Consumer<NotificationService>(
              builder: (context, notificationService, child) {
                final notifications = notificationService.notifications;
                
                if (notifications.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No hay notificaciones',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return RefreshIndicator(
                  onRefresh: notificationService.refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return NotificationTile(
                        notification: notification,
                        onTap: () => _handleNotificationTap(context, notification),
                        onDismiss: () => notificationService.deleteNotification(notification.id),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(BuildContext context, NotificationModel notification) {
    final notificationService = Provider.of<NotificationService>(context, listen: false);
    
    // Marcar como leída si no lo está
    if (!notification.isRead) {
      notificationService.markAsRead(notification.id);
    }

    // Aquí puedes agregar navegación basada en el tipo de notificación
    _navigateBasedOnNotification(context, notification);
  }

  void _navigateBasedOnNotification(BuildContext context, NotificationModel notification) {
    Navigator.pop(context); // Cerrar el bottom sheet

    switch (notification.type) {
      case NotificationType.orderApproved:
      case NotificationType.orderAccepted:
      case NotificationType.orderOnWay:
      case NotificationType.orderDelivered:
        // Navegar a los detalles del pedido
        if (notification.orderId != null) {
          // Navigator.pushNamed(context, '/order-details', arguments: notification.orderId);
          debugPrint('Navigate to order details: ${notification.orderId}');
        }
        break;
      case NotificationType.merchantApproved:
        // Navegar al panel del merchant
        // Navigator.pushNamed(context, '/merchant-dashboard');
        debugPrint('Navigate to merchant dashboard');
        break;
      case NotificationType.driverApproved:
        // Navegar al panel del driver
        // Navigator.pushNamed(context, '/driver-dashboard');
        debugPrint('Navigate to driver dashboard');
        break;
      case NotificationType.general:
        // Acción por defecto o mostrar más detalles
        break;
    }
  }
}

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const NotificationTile({
    Key? key,
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: notification.isRead ? Colors.white : Colors.blue.withOpacity(0.05),
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.withOpacity(0.2),
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon/Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    notification.getIcon(),
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      notification.body,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      notification.getTimeAgo(),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.orderApproved:
        return Colors.green;
      case NotificationType.orderAccepted:
        return Colors.blue;
      case NotificationType.orderOnWay:
        return Colors.orange;
      case NotificationType.orderDelivered:
        return Colors.green;
      case NotificationType.merchantApproved:
        return Colors.purple;
      case NotificationType.driverApproved:
        return Colors.indigo;
      case NotificationType.general:
        return Colors.grey;
    }
  }
}
