import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nicoya_now/app/features/driver/presentation/controllers/driver_controller.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';
import 'package:nicoya_now/app/features/driver/presentation/utilities/status_formatter.dart';

class AssignedOrderCard extends StatelessWidget {
  final Map<String, dynamic> order;

  const AssignedOrderCard({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final String orderId = order['order_id'] ?? '';
    final String merchantName = order['merchant']?['business_name'] ?? 'Comercio';
    final String customerName = order['customer']?['name'] ?? 'Cliente';
    final double orderTotal = order['total'] != null ? double.parse(order['total'].toString()) : 0.0;
    
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pedido #${StatusFormatter.formatOrderId(orderId)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '₡${orderTotal.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE60023),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text('Comercio: $merchantName'),
            Text('Cliente: $customerName'),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final controller = Provider.of<DriverController>(context, listen: false);
                      await controller.updateOrderStatus(orderId, 'accepted');
                    },
                    icon: Icon(Icons.check),
                    label: Text('Aceptar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    // Navigate to order details
                    Navigator.pushNamed(
                      context, 
                      Routes.driver_order_details,
                      arguments: order,
                    );
                  },
                  icon: Icon(Icons.info_outline),
                  tooltip: 'Ver detalles',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  // Using StatusFormatter utility class instead of local method
}
