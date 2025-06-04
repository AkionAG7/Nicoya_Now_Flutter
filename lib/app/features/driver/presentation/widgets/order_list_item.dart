import 'package:flutter/material.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';
import 'package:nicoya_now/app/features/driver/presentation/utilities/status_formatter.dart';

class OrderListItem extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderListItem({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final String orderId = order['order_id'] ?? '';
    final String status = order['status'] ?? '';
    final String customerName = order['customer']?['name'] ?? 'Cliente';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFE60023).withAlpha(51),
        child: Icon(Icons.delivery_dining, color: const Color(0xFFE60023)),
      ),
      title: Text(
        'Pedido #${StatusFormatter.formatOrderId(orderId)}',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text('Cliente: $customerName'),
      trailing: Chip(
        label: Text(StatusFormatter.formatStatus(status)),
        backgroundColor: StatusFormatter.getStatusColor(status).withAlpha(51),
        labelStyle: TextStyle(
          color: StatusFormatter.getStatusColor(status),
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () {
        // Navigate to order details page
        Navigator.pushNamed(
          context,
          Routes.driver_order_details,
          arguments: order,
        );
      },
    );
  }

  // Using StatusFormatter utility class instead of local methods
}
