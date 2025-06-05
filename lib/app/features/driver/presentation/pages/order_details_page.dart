import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nicoya_now/app/features/driver/presentation/controllers/driver_controller.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';

class OrderDetailsPage extends StatefulWidget {
  final Map<String, dynamic> order;

  const OrderDetailsPage({super.key, required this.order});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  late Map<String, dynamic> order;

  @override
  void initState() {
    super.initState();
    order = widget.order;
  }

  @override
  Widget build(BuildContext context) {
    final String status = order['status'] ?? '';
    final customer = order['customer'] ?? {};
    final merchant = order['merchant'] ?? {};
    final items = order['items'] ?? [];

    // Format pickup and delivery address
    final pickupAddress = merchant['address'] ?? 'Dirección no disponible';
    final deliveryAddress = customer['address'] ?? 'Dirección no disponible';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalle de Orden #${order['order_id']?.toString().substring(0, 8) ?? ''}',
        ),
        backgroundColor: const Color(0xFFE60023),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Status Card
              _buildStatusCard(status),

              const SizedBox(height: 20),

              // Locations
              _buildSectionTitle('Ubicaciones'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildLocationItem(
                        'Recoger en:',
                        merchant['business_name'] ?? 'Comercio',
                        pickupAddress,
                        Icons.store,
                      ),
                      const Divider(),
                      _buildLocationItem(
                        'Entregar a:',
                        '${customer['first_name'] ?? ''} ${customer['last_name1'] ?? ''}',
                        deliveryAddress,
                        Icons.location_on,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Order Items
              _buildSectionTitle('Artículos'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // This would typically come from your order data
                      // Here's a placeholder for demonstration
                      if (items.isEmpty) ...[
                        ListTile(
                          title: Text(
                            'Pedido de ${merchant['business_name'] ?? 'comercio'}',
                          ),
                          subtitle: Text(
                            'Ver detalles completos en la aplicación',
                          ),
                          trailing: Text(
                            '₡${order['total_amount']?.toString() ?? '0'}',
                          ),
                        ),
                      ] else ...[
                        for (var item in items)
                          ListTile(
                            title: Text(item['product_name'] ?? 'Producto'),
                            subtitle: Text(
                              'Cantidad: ${item['quantity'] ?? 1}',
                            ),
                            trailing: Text('₡${item['price'] ?? 0}'),
                          ),
                      ],
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '₡${order['total_amount']?.toString() ?? '0'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Action buttons
              _buildActionButtons(order['order_id'] ?? '', status),
            ],
          ),
        ),
      ),
    );
  }  Widget _buildStatusCard(String status) {
    Color statusColor;
    String statusText;

    switch (status) {
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'Pendiente';
        break;
      case 'in_process':
        statusColor = Colors.amber;
        statusText = 'Disponible para aceptar';
        break;
      case 'assigned':
        statusColor = Colors.blue;
        statusText = 'Asignado';
        break;
      case 'picked_up':
        statusColor = Colors.purple;
        statusText = 'Recogido';
        break;
      case 'on_way':
        statusColor = Colors.indigo;
        statusText = 'En camino';
        break;
      case 'delivered':
        statusColor = Colors.green;
        statusText = 'Entregado';
        break;
      case 'cancelled':
        statusColor = Colors.red;
        statusText = 'Cancelado';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Desconocido';
    }

    return Card(
      color: statusColor.withAlpha(51),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: statusColor),
            const SizedBox(width: 10),
            Text(
              'Estado: $statusText',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: statusColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildLocationItem(
    String label,
    String name,
    String address,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFE60023)),
      title: Text(name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          Text(address),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(Icons.navigation, color: Colors.blue),
        onPressed: () {
          // Open maps app with navigation
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Abriendo navegación...')),
          );
        },
      ),
    );
  }  Widget _buildActionButtons(String orderId, String status) {
    switch (status) {
      case 'in_process':
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.navigation),
                label: const Text('Navegar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  // Open map navigation
                  Navigator.pushNamed(context, Routes.order_Success);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.local_shipping),
                label: const Text('Aceptar pedido'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE60023),
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final controller = Provider.of<DriverController>(
                    context,
                    listen: false,
                  );
                  final success = await controller.updateOrderStatus(
                    orderId,
                    'on_way',
                  );
                  if (success && mounted) {
                    setState(() {
                      order['status'] = 'on_way';
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Pedido aceptado correctamente'),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        );
      case 'assigned':
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.navigation),
                label: const Text('Navegar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  // Open map navigation
                  Navigator.pushNamed(context, Routes.order_Success);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.local_shipping),
                label: const Text('En Camino'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE60023),
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final controller = Provider.of<DriverController>(
                    context,
                    listen: false,
                  );                  final success = await controller.updateOrderStatus(
                    orderId,
                    'on_way',
                  );                  if (success && mounted) {
                    setState(() {
                      order['status'] = 'on_way';
                    });
                  }
                },
              ),
            ),
          ],
        );
      case 'on_way':
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.navigation),
                label: const Text('Navegar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  // Open map navigation
                  Navigator.pushNamed(context, Routes.order_Success);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.home),
                label: const Text('Entregar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE60023),
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final controller = Provider.of<DriverController>(
                    context,
                    listen: false,
                  );
                  final success = await controller.updateOrderStatus(
                    orderId,
                    'delivered',
                  );
                  if (success && mounted) {
                    setState(() {
                      order['status'] = 'delivered';
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('¡Orden entregada exitosamente!'),
                      ),
                    );

                    Future.delayed(const Duration(seconds: 2), () {
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    });
                  }
                },
              ),
            ),
          ],
        );
      case 'delivered':
        return Center(
          child: Column(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 10),
              const Text(
                'Orden entregada exitosamente',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Volver'),
              ),
            ],
          ),
        );
      default:
        return ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Volver'),
        );
    }
  }
}
