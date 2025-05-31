enum NotificationType {
  orderApproved('order_approved'),
  orderAccepted('order_accepted'),
  orderOnWay('order_on_way'),
  orderDelivered('order_delivered'),
  merchantApproved('merchant_approved'),
  driverApproved('driver_approved'),
  general('general');

  const NotificationType(this.value);
  final String value;

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.general,
    );
  }
}

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final String? orderId;
  final String? merchantId;
  final String? driverId;
  final bool isRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.orderId,
    this.merchantId,
    this.driverId,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: NotificationType.fromString(json['type'] as String),
      orderId: json['order_id'] as String?,
      merchantId: json['merchant_id'] as String?,
      driverId: json['driver_id'] as String?,
      isRead: json['is_read'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'body': body,
      'type': type.value,
      'order_id': orderId,
      'merchant_id': merchantId,
      'driver_id': driverId,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    NotificationType? type,
    String? orderId,
    String? merchantId,
    String? driverId,
    bool? isRead,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      orderId: orderId ?? this.orderId,
      merchantId: merchantId ?? this.merchantId,
      driverId: driverId ?? this.driverId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Ahora mismo';
    }
  }

  String getIcon() {
    switch (type) {
      case NotificationType.orderApproved:
        return '🎉';
      case NotificationType.orderAccepted:
        return '🚗';
      case NotificationType.orderOnWay:
        return '🚚';
      case NotificationType.orderDelivered:
        return '✅';
      case NotificationType.merchantApproved:
        return '🏪';
      case NotificationType.driverApproved:
        return '🚗';
      case NotificationType.general:
        return '📢';
    }
  }
}
