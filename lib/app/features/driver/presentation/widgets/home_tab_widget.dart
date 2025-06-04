import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nicoya_now/app/features/driver/presentation/controllers/driver_controller.dart';
import 'package:nicoya_now/app/features/driver/presentation/widgets/improved_order_tracking.dart';
import 'package:nicoya_now/app/features/driver/presentation/widgets/merchant_map_widget_fixed.dart';
import 'package:nicoya_now/app/features/driver/presentation/widgets/assigned_order_card.dart';
import 'package:nicoya_now/app/features/driver/presentation/widgets/order_list_item.dart';
import 'package:nicoya_now/app/features/driver/presentation/widgets/available_order_card.dart';

class HomeTabWidget extends StatefulWidget {
  final DriverController controller;
  final bool isAvailable;
  final Function debugOrdersCallback;

  const HomeTabWidget({
    super.key,
    required this.controller,
    required this.isAvailable,
    required this.debugOrdersCallback,
  });

  @override
  HomeTabWidgetState createState() => HomeTabWidgetState();
}

class HomeTabWidgetState extends State<HomeTabWidget> {
  List<Map<String, dynamic>> _availableOrders = [];
  bool _isLoadingAvailableOrders = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableOrders();
  }

  Future<void> _loadAvailableOrders() async {
    if (!widget.isAvailable) return;

    setState(() {
      _isLoadingAvailableOrders = true;
    });

    try {
      final availableOrders = await widget.controller.fetchAvailableOrders();
      setState(() {
        _availableOrders = availableOrders;
        _isLoadingAvailableOrders = false;
      });
    } catch (e) {
      //ignore: avoid_print
      print('Error al cargar pedidos disponibles: $e');
      setState(() {
        _isLoadingAvailableOrders = false;
      });
    }
  }

  Future<void> _acceptOrder(String orderId) async {
    setState(() {
      _isLoadingAvailableOrders = true;
    });

    try {
      final success = await widget.controller.acceptOrderRPC(orderId);
      if (success) {
        // Reload available orders after accepting one
        //ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pedido aceptado correctamente')),
        );
        await _loadAvailableOrders();
      } else {
        ScaffoldMessenger.of(
          //ignore: use_build_context_synchronously
          context,
        ).showSnackBar(SnackBar(content: Text('Error al aceptar pedido')));
        setState(() {
          _isLoadingAvailableOrders = false;
        });
      }
    } catch (e) {
      //ignore: avoid_print
      print('Error al aceptar pedido: $e');

      ScaffoldMessenger.of(
        //ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() {
        _isLoadingAvailableOrders = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format driver data for display
    final driverData = widget.controller.currentDriverData;
    final String firstName = driverData?['first_name'] ?? '';
    final String vehicleType = driverData?['vehicle_type'] ?? '';

    // Filter orders by status
    final List<Map<String, dynamic>> assignedOrders =
        widget.controller.activeOrders
            .where((order) => order['status'] == 'pending')
            .toList();

    // Show orders that are in_process, accepted, pending with assignments, etc.
    // Explicitly include all status types we want to display - with error handling
    List<Map<String, dynamic>> inProgressOrders = [];

    try {
      inProgressOrders =
          widget.controller.activeOrders.where((order) {
            try {
              final status = order['status']?.toString() ?? '';

              // Include orders with these statuses
              bool isActiveStatus =
                  status == 'in_process' ||
                  status == 'accepted' ||
                  status == 'on_way';

              // Also include pending orders that have assignments
              bool isPendingWithAssignment =
                  status == 'pending' && order['assigned_at'] != null;

              return isActiveStatus ||
                  isPendingWithAssignment ||
                  status == 'pending';
            } catch (e) {
              //ignore: avoid_print
              print('Error processing order: $e');
              return false;
            }
          }).toList();
      //ignore: avoid_print
      print(
        'Active orders: ${widget.controller.activeOrders.length}, In progress: ${inProgressOrders.length}',
      );
    } catch (e) {
      //ignore: avoid_print
      print('Error filtering orders: $e');
      // Fall back to empty list if there's an error
      inProgressOrders = [];
    }

    // If there's an active in-progress order, show the improved tracking screen
    if (inProgressOrders.isNotEmpty) {
      Map<String, dynamic> activeOrder = inProgressOrders.first;
      //ignore: avoid_print
      print(
        'Selected order for tracking: ${activeOrder['order_id']}, Status: ${activeOrder['status']}',
      );
      return ImprovedOrderTrackingWidget(
        controller: widget.controller,
        activeOrder: activeOrder,
      );
    }

    // Otherwise show the regular home tab
    return RefreshIndicator(
      onRefresh: _loadAvailableOrders,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
                              widget.isAvailable
                                  ? 'Estado: Activo y recibiendo pedidos'
                                  : 'Estado: Inactivo',
                              style: TextStyle(
                                fontSize: 16,
                                color:
                                    widget.isAvailable
                                        ? Colors.green
                                        : Colors.grey,
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

              // Available orders section - NEW SECTION
              if (widget.isAvailable) ...[
                const SizedBox(height: 24),
                Card(
                  elevation: 4,
                  color: Colors.blue[50],
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
                            Row(
                              children: [
                                Icon(Icons.delivery_dining, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(
                                  'Pedidos disponibles',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[800],
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(Icons.refresh),
                              onPressed: _loadAvailableOrders,
                              tooltip: 'Actualizar pedidos disponibles',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Show loading indicator or available orders
                        _isLoadingAvailableOrders
                            ? Center(child: CircularProgressIndicator())
                            : _availableOrders.isEmpty
                            ? Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 24.0,
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No hay pedidos disponibles en este momento',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[700],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            )
                            : ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _availableOrders.length,
                              itemBuilder: (context, index) {
                                final order = _availableOrders[index];
                                return AvailableOrderCard(
                                  order: order,
                                  onAccept:
                                      () => _acceptOrder(order['order_id']),
                                );
                              },
                            ),
                      ],
                    ),
                  ),
                ),
              ],

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
                            Icon(
                              Icons.notification_important,
                              color: Colors.orange,
                            ),
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
                        ...assignedOrders.map(
                          (order) => AssignedOrderCard(order: order),
                        ),
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
                        driverLocation:
                            driverData != null &&
                                    driverData['current_latitude'] != null &&
                                    driverData['current_longitude'] != null
                                ? LatLng(
                                  double.parse(
                                    driverData['current_latitude'].toString(),
                                  ),
                                  double.parse(
                                    driverData['current_longitude'].toString(),
                                  ),
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
                              Provider.of<HomeTabChangeNotifier>(
                                context,
                                listen: false,
                              ).setSelectedIndex(1);
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
                          itemCount:
                              inProgressOrders.length > 2
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

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () => widget.debugOrdersCallback(),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text(
                  'Depurar pedidos',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
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
