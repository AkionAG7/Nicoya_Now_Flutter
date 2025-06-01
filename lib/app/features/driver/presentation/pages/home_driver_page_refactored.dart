import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nicoya_now/app/features/driver/presentation/controllers/driver_controller.dart';
import 'package:nicoya_now/app/features/driver/presentation/managers/location_manager.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';
import 'package:nicoya_now/Icons/nicoya_now_icons_icons.dart';

// Widgets
import 'package:nicoya_now/app/features/driver/presentation/widgets/home_tab_widget.dart';
import 'package:nicoya_now/app/features/driver/presentation/widgets/active_orders_tab_widget.dart';
import 'package:nicoya_now/app/features/driver/presentation/widgets/profile_tab_widget.dart';

class HomeDriverPage extends StatefulWidget {
  const HomeDriverPage({Key? key}) : super(key: key);

  @override
  _HomeDriverPageState createState() => _HomeDriverPageState();
}

class _HomeDriverPageState extends State<HomeDriverPage> with WidgetsBindingObserver {
  final LocationManager _locationManager = LocationManager();
  int _selectedIndex = 0;
  bool _isAvailable = true;
  late HomeTabChangeNotifier _tabChangeNotifier;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabChangeNotifier = HomeTabChangeNotifier();
    _tabChangeNotifier.addListener(_onTabChangeFromChild);
    
    // Initialize driver data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<DriverController>(context, listen: false);
      _locationManager.init(context, controller);
      _initDriverAndLocation();
    });
  }
  
  void _onTabChangeFromChild() {
    setState(() {
      _selectedIndex = _tabChangeNotifier.selectedIndex;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _locationManager.dispose();
    _tabChangeNotifier.removeListener(_onTabChangeFromChild);
    _tabChangeNotifier.dispose();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Update location when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      _locationManager.updateLocation();
    }
  }
  
  Future<void> _initDriverAndLocation() async {
    await _loadDriverData();
    await _locationManager.requestLocationPermissions();
    _startLocationUpdates();
  }
  
  void _startLocationUpdates() {
    _locationManager.startLocationUpdates((lat, lng) {
      // Optional callback when location updates
      // print('Location updated: $lat, $lng');
    });
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

  void _debugOrders() async {
    final controller = Provider.of<DriverController>(context, listen: false);
    
    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Depurando pedidos...'),
          ],
        ),
      ),
    );
    
    try {
      final String specificOrderId = 'f50a1fbb-d76b-4c0e-af0e-d20015396591';
      
      // Llamar a los métodos de depuración
      await controller.loadActiveOrdersWithDebug();
      await controller.forceCheckSpecificOrder(); 
      
      // Check if the problematic order exists in controller
      _orderExistsInController(specificOrderId, controller);
      
      // Cerrar el diálogo y mostrar resultados
      if (mounted) {
        Navigator.of(context).pop();
        
        // Mostrar mensaje con conteo de pedidos
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pedidos cargados: ${controller.activeOrders.length}'),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Ver logs',
              onPressed: () {
                print('Ver logs de depuración');
              },
            ),
          ),
        );
      }
    } catch (e) {
      // Mostrar error
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
  
  bool _orderExistsInController(String specificOrderId, DriverController controller) {
    try {
      final exists = controller.activeOrders.any((order) => order['order_id'] == specificOrderId);
      if (exists) {
        print('Found specific order $specificOrderId in controller');
      } else {
        print('Specific order $specificOrderId NOT found in controller');
      }
      return exists;
    } catch (e) {
      print('Error checking for specific order: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _tabChangeNotifier,
      child: Scaffold(
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
                HomeTabWidget(
                  controller: controller,
                  isAvailable: _isAvailable,
                  debugOrdersCallback: _debugOrders,
                ),
                ActiveOrdersTabWidget(controller: controller),
                ProfileTabWidget(
                  controller: controller,
                  onSignOut: _signOut,
                ),
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
      ),
    );
  }
}
