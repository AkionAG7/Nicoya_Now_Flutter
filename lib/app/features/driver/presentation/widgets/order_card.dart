import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nicoya_now/app/features/driver/presentation/controllers/driver_controller.dart';
import 'package:nicoya_now/app/features/driver/presentation/widgets/active_order_tracking.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';
import 'package:nicoya_now/app/features/driver/presentation/utilities/status_formatter.dart';

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderCard({super.key, required this.order});  @override
  Widget build(BuildContext context) {
    final String orderId = order['order_id'] ?? '';
    final String status = order['status'] ?? '';
    final String customerName = order['customerName'] ?? 'Cliente';
    final String merchantName = order['merchantName'] ?? 'Comercio';
    final String deliveryAddress =
        order['delivery_address'] ?? 'Dirección de entrega';
    final String pickupAddress =
        order['merchant']?['address'] ?? 'Dirección de recogida';

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pedido #${StatusFormatter.formatOrderId(orderId)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Chip(
                  label: Text(StatusFormatter.formatStatus(status)),
                  backgroundColor: StatusFormatter.getStatusColor(
                    status,
                  ).withAlpha(51),
                  labelStyle: TextStyle(
                    color: StatusFormatter.getStatusColor(status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Divider(),
            _buildOrderDetail('Comercio', merchantName),
            _buildOrderDetail('Cliente', customerName),
            _buildOrderDetail('Recoger en', pickupAddress),
            _buildOrderDetail('Entregar en', deliveryAddress),
            Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _buildOrderActions(context, order),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          Expanded(child: Text(value, style: TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  List<Widget> _buildOrderActions(
    BuildContext context,
    Map<String, dynamic> order,
  ) {
    final String status = order['status'] ?? '';
    final String orderId = order['order_id'] ?? '';
    final controller = Provider.of<DriverController>(context, listen: false);

    switch (status) {
      // Using 'pending' for orders that would have been 'assigned'
      case 'pending':
        return [
          ElevatedButton.icon(
            icon: Icon(Icons.thumb_up),
            label: Text('Aceptar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              // Mostrar indicador de carga
              showDialog(
                context: context,
                barrierDismissible: false,
                builder:
                    (context) =>
                        const Center(child: CircularProgressIndicator()),
              );

              // Usar el método acceptOrderRPC
              final success = await controller.acceptOrderRPC(orderId);

              // Cerrar indicador de carga
              //ignore: use_build_context_synchronously
              Navigator.of(context).pop();

              // Mostrar mensaje de resultado
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Pedido aceptado correctamente')),
                );
              }
            },
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.navigation),
            label: Text('Navegar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              // Open map navigation - use the active order tracking
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ActiveOrderTrackingWidget(
                        controller: controller,
                        activeOrder: order,
                      ),
                ),
              );
            },
          ),
        ];

      case 'accepted':
        return [
          ElevatedButton.icon(
            icon: Icon(Icons.navigation),
            label: Text('Navegar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              // Open map navigation - use the active order tracking
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ActiveOrderTrackingWidget(
                        controller: controller,
                        activeOrder: order,
                      ),
                ),
              );
            },
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.check),
            label: Text('Recoger'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE60023),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              // Mostrar indicador de carga
              showDialog(
                context: context,
                barrierDismissible: false,
                builder:
                    (context) =>
                        const Center(child: CircularProgressIndicator()),
              );

              // Usar el método markOrderPickedUp
              final success = await controller.markOrderPickedUp(orderId);

              // Cerrar indicador de carga
              //ignore: use_build_context_synchronously
              Navigator.of(context).pop();

              // Mostrar mensaje de resultado
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Pedido recogido correctamente')),
                );
              }
            },
          ),
        ];
      case 'in_process':
      case 'on_way':
        return [
          ElevatedButton.icon(
            icon: Icon(Icons.navigation),
            label: Text('Navegar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              // Open map navigation - use the active order tracking
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ActiveOrderTrackingWidget(
                        controller: controller,
                        activeOrder: order,
                      ),
                ),
              );
            },
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.check_circle),
            label: Text('Entregar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE60023),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              // Mostrar indicador de carga
              showDialog(
                context: context,
                barrierDismissible: false,
                builder:
                    (context) =>
                        const Center(child: CircularProgressIndicator()),
              );

              // Usar el método markOrderDelivered
              final success = await controller.markOrderDelivered(orderId);

              // Cerrar indicador de carga
              //ignore: use_build_context_synchronously
              Navigator.of(context).pop();

              // Mostrar mensaje de resultado
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Pedido entregado correctamente')),
                );
              }
            },
          ),
        ];
      default:
        return [
          ElevatedButton.icon(
            icon: Icon(Icons.info_outline),
            label: Text('Ver Detalles'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              // Navigate to order details page
              Navigator.pushNamed(
                context,
                Routes.driver_order_details,
                arguments: order,
              );
            },
          ),
        ];
    }
  }

  // Using StatusFormatter utility class instead of local methods
}
