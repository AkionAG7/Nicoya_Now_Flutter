import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nicoya_now/app/features/driver/presentation/controllers/driver_controller.dart';
import 'package:nicoya_now/app/features/ubication/delivery_tracking/ubication_controller.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';
import 'package:nicoya_now/Icons/nicoya_now_icons_icons.dart';
import 'package:nicoya_now/app/features/driver/presentation/widgets/active_order_tracking.dart';
import 'package:nicoya_now/app/features/driver/presentation/widgets/improved_order_tracking.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nicoya_now/app/features/driver/presentation/widgets/merchant_map_widget.dart';

// Helper class for min function
class Math {
  static int min(int a, int b) => a < b ? a : b;
}

class HomeDriverPage extends StatefulWidget {
  const HomeDriverPage({Key? key}) : super(key: key);

  @override
  _HomeDriverPageState createState() => _HomeDriverPageState();
}

class _HomeDriverPageState extends State<HomeDriverPage> with WidgetsBindingObserver {
  final UbicacionController ubicacionController = UbicacionController();
    int _selectedIndex = 0;
  bool _isAvailable = true;
    // Location update stream subscription
  StreamSubscription? _locationSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Request location permissions and initialize
    _initLocationAndPermissions();
    
    // Initialize driver data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDriverData();
      
      // Start location updates
      _startLocationUpdates();
    });
  }
  void _startLocationUpdates() {
    _locationSubscription = ubicacionController.escucharUbicacion().listen((ubicacion) {
      // Update driver location in database periodically
      final controller = Provider.of<DriverController>(context, listen: false);
      controller.updateLocation(ubicacion.latitude!, ubicacion.longitude!);
    });
  }@override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _locationSubscription?.cancel();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Update location when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      _updateDriverLocation();
    }
  }
  
  Future<void> _initLocationAndPermissions() async {
    try {
      final permiso = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Permiso de Ubicación"),
            content: const Text(
              "¿Quieres permitir que esta app acceda a tu ubicación para brindarte un mejor servicio?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Permitir"),
              ),
            ],
          );
        },
      );

      if (permiso == true) {
        await _updateDriverLocation();
      }
    } catch (e) {
      print("Error initializing location: $e");
    }
  }    Future<void> _updateDriverLocation() async {
    try {
      final ubicacion = await ubicacionController.obtenerUbicacion();
      if (ubicacion != null) {
        print("Ubicación obtenida: ${ubicacion.latitude}, ${ubicacion.longitude}");
        
        // Update driver location in database
        final controller = Provider.of<DriverController>(context, listen: false);
        await controller.updateLocation(ubicacion.latitude!, ubicacion.longitude!);
      } else {
        print("No se pudo obtener la ubicación");
      }
    } catch (e) {
      print("Error updating location: $e");
    }
  }
  
  Future<void> _loadDriverData() async {
    final controller = Provider.of<DriverController>(context, listen: false);
    await controller.loadDriverData();
    
    if (controller.currentDriverData != null && 
        controller.currentDriverData!.containsKey('is_available')) {
      setState(() {
        _isAvailable = controller.currentDriverData!['is_available'] ?? false;
      });
    }
  }
  
  Future<void> _toggleAvailability() async {
    final newStatus = !_isAvailable;
    
    final controller = Provider.of<DriverController>(context, listen: false);
    await controller.updateAvailability(newStatus);
    
    setState(() {
      _isAvailable = newStatus;
    });
  }
  
  void _signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(Routes.preLogin, (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nicoya Now - Repartidor'),
        backgroundColor: const Color(0xFFE60023),
        foregroundColor: Colors.white,
        actions: [
          Switch(
            value: _isAvailable,
            onChanged: (value) => _toggleAvailability(),
            activeColor: Colors.green,
            activeTrackColor: Colors.green.shade200,
            inactiveTrackColor: Colors.grey.shade400,
            inactiveThumbColor: Colors.grey,
          ),
          Text(
            _isAvailable ? 'Activo' : 'Inactivo',
            style: TextStyle(
              color: _isAvailable ? Colors.green : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Consumer<DriverController>(
        builder: (context, controller, child) {
          if (controller.state == DriverState.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (controller.state == DriverState.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.error ?? 'Error desconocido',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadDriverData,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          
          // Use IndexedStack to maintain state of each tab
          return IndexedStack(
            index: _selectedIndex,
            children: [
              _buildHomeTab(controller),
              _buildActiveOrdersTab(controller),
              _buildProfileTab(controller),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFE60023),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delivery_dining),
            label: 'Entregas',
          ),
          BottomNavigationBarItem(
            icon: Icon(NicoyaNowIcons.usuario),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
    Widget _buildHomeTab(DriverController controller) {
    // Format driver data for display
    final driverData = controller.currentDriverData;
    final String firstName = driverData?['first_name'] ?? '';
    final String vehicleType = driverData?['vehicle_type'] ?? '';
    
    // Check if there are active orders for delivery tracking
    final bool hasActiveOrder = controller.activeOrders.isNotEmpty;
    
    // If there's an active order, show the improved tracking screen
    if (hasActiveOrder) {
      Map<String, dynamic> activeOrder = controller.activeOrders.first;
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
                            _isAvailable
                                ? 'Estado: Activo y recibiendo pedidos'
                                : 'Estado: Inactivo',
                            style: TextStyle(
                              fontSize: 16,
                              color: _isAvailable ? Colors.green : Colors.grey,
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
            
            const SizedBox(height: 24),              // Map card showing merchant locations
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
                            setState(() => _selectedIndex = 1);
                          },
                          child: Text('Ver todas'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (controller.activeOrders.isEmpty)
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
                        itemCount: controller.activeOrders.length > 2
                            ? 2
                            : controller.activeOrders.length,
                        itemBuilder: (context, index) {
                          final order = controller.activeOrders[index];
                          return _buildOrderListItem(order);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }  // Los métodos _buildMerchantMap y _loadMerchantLocations se han eliminado
  // ya que esta funcionalidad ahora está en la clase MerchantMapWidget
  
  Widget _buildActiveOrdersTab(DriverController controller) {
    if (controller.activeOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hourglass_empty,
              size: 72,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay entregas activas',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => controller.loadActiveOrders(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE60023),
              ),
              child: const Text(
                'Actualizar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () => controller.loadActiveOrders(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: controller.activeOrders.length,
        itemBuilder: (context, index) {
          final order = controller.activeOrders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }
  
  Widget _buildProfileTab(DriverController controller) {
    // Format driver data for display
    final driverData = controller.currentDriverData;
    final String firstName = driverData?['first_name'] ?? '';
    final String lastName1 = driverData?['last_name1'] ?? '';
    final String lastName2 = driverData?['last_name2'] ?? '';
    final String phone = driverData?['phone'] ?? '';
    final String vehicleType = driverData?['vehicle_type'] ?? '';
    final String licenseNumber = driverData?['license_number'] ?? '';
    final bool isVerified = driverData?['is_verified'] ?? false;
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile header
            CircleAvatar(
              backgroundColor: const Color(0xFFE60023),
              radius: 50,
              child: Icon(
                Icons.person,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '$firstName $lastName1 $lastName2',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Repartidor ${isVerified ? 'Verificado' : 'Pendiente de verificación'}',
              style: TextStyle(
                fontSize: 16,
                color: isVerified ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            
            // Profile details
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
                    Text(
                      'Información personal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildProfileField('Teléfono', phone),
                    _buildProfileField('Tipo de vehículo', vehicleType),
                    _buildProfileField('Número de licencia', licenseNumber),
                    _buildProfileField('Estado', isVerified ? 'Verificado' : 'Pendiente de verificación'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Account actions
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
                    Text(
                      'Cuenta',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: Icon(Icons.help_outline, color: const Color(0xFFE60023)),
                      title: Text('Ayuda'),
                      trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // Show help dialog
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.exit_to_app, color: Colors.red),
                      title: Text('Cerrar sesión'),
                      onTap: _signOut,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProfileField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
    
  Widget _buildOrderListItem(Map<String, dynamic> order) {
    final String orderId = order['order_id'] ?? '';
    final String status = order['status'] ?? '';
    final String customerName = order['customer']?['name'] ?? 'Cliente';
    
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFE60023).withOpacity(0.2),
        child: Icon(
          Icons.delivery_dining,
          color: const Color(0xFFE60023),
        ),
      ),
      title: Text(
        'Pedido #${orderId.substring(0, Math.min(8, orderId.length))}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text('Cliente: $customerName'),
      trailing: Chip(
        label: Text(_formatStatus(status)),
        backgroundColor: _getStatusColor(status).withOpacity(0.2),
        labelStyle: TextStyle(
          color: _getStatusColor(status),
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
  
  Widget _buildOrderCard(Map<String, dynamic> order) {
    final String orderId = order['order_id'] ?? '';
    final String status = order['status'] ?? '';
    final String customerName = order['customer']?['name'] ?? 'Cliente';
    final String merchantName = order['merchant']?['business_name'] ?? 'Comercio';
    final String deliveryAddress = order['delivery_address'] ?? 'Dirección de entrega';
    final String pickupAddress = order['merchant']?['address'] ?? 'Dirección de recogida';
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16.0),
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
                  'Pedido #${orderId.substring(0, Math.min(8, orderId.length))}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text(_formatStatus(status)),
                  backgroundColor: _getStatusColor(status).withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: _getStatusColor(status),
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
              children: _buildOrderActions(order),
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
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  List<Widget> _buildOrderActions(Map<String, dynamic> order) {
    final String status = order['status'] ?? '';
    final String orderId = order['order_id'] ?? '';
    
    switch (status) {
      case 'assigned':
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
              final activeOrder = order;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ActiveOrderTrackingWidget(
                    controller: Provider.of<DriverController>(context, listen: false),
                    activeOrder: activeOrder,
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
              final controller = Provider.of<DriverController>(context, listen: false);
              await controller.updateOrderStatus(orderId, 'picked_up');
            },
          ),
        ];
      case 'picked_up':
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
              final activeOrder = order;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ActiveOrderTrackingWidget(
                    controller: Provider.of<DriverController>(context, listen: false),
                    activeOrder: activeOrder,
                  ),
                ),
              );
            },
          ),
          ElevatedButton.icon(
            icon: Icon(Icons.home),
            label: Text('Entregar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE60023),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final controller = Provider.of<DriverController>(context, listen: false);
              await controller.updateOrderStatus(orderId, 'delivered');
            },
          ),
        ];
      case 'on_the_way':
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
              final activeOrder = order;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ActiveOrderTrackingWidget(
                    controller: Provider.of<DriverController>(context, listen: false),
                    activeOrder: activeOrder,
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
              final controller = Provider.of<DriverController>(context, listen: false);
              await controller.updateOrderStatus(orderId, 'delivered');
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
  
  String _formatStatus(String status) {
    switch (status) {
      case 'assigned':
        return 'Asignado';
      case 'picked_up':
        return 'Recogido';
      case 'on_the_way':
        return 'En camino';
      case 'delivered':
        return 'Entregado';
      default:
        return 'Desconocido';
    }
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'assigned':
        return Colors.orange;
      case 'picked_up':
        return Colors.blue;
      case 'on_the_way':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}


