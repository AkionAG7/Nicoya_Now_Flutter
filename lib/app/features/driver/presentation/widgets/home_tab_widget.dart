import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nicoya_now/app/features/driver/presentation/controllers/driver_controller.dart';
import 'package:nicoya_now/app/features/driver/presentation/widgets/improved_order_tracking.dart';
import 'package:nicoya_now/app/features/driver/presentation/widgets/merchant_map_widget_fixed.dart';
import 'package:nicoya_now/app/features/driver/presentation/widgets/assigned_order_card.dart';
import 'package:nicoya_now/app/features/driver/presentation/widgets/order_list_item.dart';

class HomeTabWidget extends StatelessWidget {
  final DriverController controller;
  final bool isAvailable;
  final Function debugOrdersCallback;

  const HomeTabWidget({
    Key? key,
    required this.controller,
    required this.isAvailable,
    required this.debugOrdersCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format driver data for display
    final driverData = controller.currentDriverData;
    final String firstName = driverData?['first_name'] ?? '';
    final String vehicleType = driverData?['vehicle_type'] ?? '';
      
    // Filter orders by status
    final List<Map<String, dynamic>> assignedOrders = controller.activeOrders
        .where((order) => order['status'] == 'pending')
        .toList();
    
    // Show orders that are in_process, accepted, pending with assignments, etc.
    // Explicitly include all status types we want to display - with error handling
    List<Map<String, dynamic>> inProgressOrders = [];
      
    try {
      inProgressOrders = controller.activeOrders
          .where((order) {
            try {
              final status = order['status']?.toString() ?? '';
              
              // Include orders with these statuses
              bool isActiveStatus = status == 'in_process' || 
                                   status == 'accepted' || 
                                   status == 'on_way';
              
              // Also include pending orders that have assignments
              bool isPendingWithAssignment = status == 'pending' && 
                                           order['assigned_at'] != null;
                                           
              return isActiveStatus || isPendingWithAssignment || status == 'pending';
            } catch (e) {
              print('Error processing order: $e');
              return false;
            }
          })
          .toList();
          
      print('Active orders: ${controller.activeOrders.length}, In progress: ${inProgressOrders.length}');
    } catch (e) {
      print('Error filtering orders: $e');
      // Fall back to empty list if there's an error
      inProgressOrders = [];
    }
    
    // If there's an active in-progress order, show the improved tracking screen
    if (inProgressOrders.isNotEmpty) {
      Map<String, dynamic> activeOrder = inProgressOrders.first;
      print('Selected order for tracking: ${activeOrder['order_id']}, Status: ${activeOrder['status']}');
      return ImprovedOrderTrackingWidget(controller: controller, activeOrder: activeOrder);
    }

    // Otherwise show the regular home tab
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFFE60023),
                      radius: 30,
                      child: Icon(
                        Icons.delivery_dining,
                        size: 35,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¡Hola, $firstName!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Vehículo: $vehicleType',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isAvailable
                                ? 'Estado: Activo y recibiendo pedidos'
                                : 'Estado: Inactivo',
                            style: TextStyle(
                              fontSize: 16,
                              color: isAvailable ? Colors.green : Colors.grey,
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
            
            // Assigned orders section (if any)
            if (assignedOrders.isNotEmpty) ...[
              const SizedBox(height: 24),
              Card(
                elevation: 4,
                color: Colors.orange[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.notification_important, color: Colors.orange),
                          const SizedBox(width: 8),
                          Text(
                            'Pedidos nuevos asignados',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...assignedOrders.map((order) => AssignedOrderCard(order: order)).toList(),
                    ],
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Map card showing merchant locations
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Mapa de comercios',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 300,
                    child: MerchantMapWidget(
                      driverLocation: controller.currentDriverData != null && 
                          controller.currentDriverData!['current_latitude'] != null && 
                          controller.currentDriverData!['current_longitude'] != null 
                          ? LatLng(
                              double.parse(controller.currentDriverData!['current_latitude'].toString()),
                              double.parse(controller.currentDriverData!['current_longitude'].toString()),
                            ) 
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Active orders card (preview)
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Entregas activas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Change tab to active orders
                            Provider.of<HomeTabChangeNotifier>(context, listen: false).setSelectedIndex(1);
                          },
                          child: Text('Ver todas'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (inProgressOrders.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 48,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No tienes entregas activas',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: inProgressOrders.length > 2
                            ? 2
                            : inProgressOrders.length,
                        itemBuilder: (context, index) {
                          final order = inProgressOrders[index];
                          return OrderListItem(order: order);
                        },
                      ),
                  ],
                ),
              ),
            ),
            
            ElevatedButton(
              onPressed: () => debugOrdersCallback(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text(
                'Depurar pedidos',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Provider para gestionar el cambio de tabs desde widgets hijos
class HomeTabChangeNotifier extends ChangeNotifier {
  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }
}
