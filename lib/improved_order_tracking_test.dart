import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nicoya_now/app/features/driver/presentation/controllers/driver_controller.dart';
import 'package:nicoya_now/app/features/driver/presentation/widgets/improved_order_tracking.dart';

// Creamos un controlador de prueba que extiende DriverController
class TestDriverController extends ChangeNotifier {
  Map<String, dynamic>? _currentDriverData;
  List<Map<String, dynamic>> _activeOrders = [];
  String? _error;
  
  DriverState _state = DriverState.loaded;
  
  DriverState get state => _state;
  String? get error => _error;
  Map<String, dynamic>? get currentDriverData => _currentDriverData;
  List<Map<String, dynamic>> get activeOrders => _activeOrders;
  
  void setDriverData(Map<String, dynamic> data) {
    _currentDriverData = data;
    notifyListeners();
  }
  
  void setActiveOrders(List<Map<String, dynamic>> orders) {
    _activeOrders = orders;
    notifyListeners();
  }
  
  Future<bool> updateOrderStatus(String orderId, String status) async {
    // Este método es necesario para que ImprovedOrderTrackingWidget funcione correctamente
    return true;
  }
  
  Future<void> updateLocation(double latitude, double longitude) async {
    // Este método es necesario para que ImprovedOrderTrackingWidget funcione correctamente
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OrderTrackingTestApp());
}

class OrderTrackingTestApp extends StatelessWidget {
  const OrderTrackingTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChangeNotifierProvider(
        create: (_) => TestDriverController(),
        child: const OrderTrackingTestPage(),
      ),
    );
  }
}

class OrderTrackingTestPage extends StatefulWidget {
  const OrderTrackingTestPage({Key? key}) : super(key: key);

  @override
  State<OrderTrackingTestPage> createState() => _OrderTrackingTestPageState();
}

class _OrderTrackingTestPageState extends State<OrderTrackingTestPage> {
  // Datos de ejemplo para probar el tracking
  final Map<String, dynamic> sampleOrder = {
    'order_id': '12345678',
    'status': 'assigned',
    'merchant': {
      'merchant_id': 'xyz789',
      'business_name': 'Restaurante El Parque',
      'address': '25 mts del Liceo de Nicoya',
      'latitude': '10.14353',
      'longitude': '-85.45195',
    },
    'customer': {
      'name': 'Juan Pérez',
      'phone': '+506 8765 4321',
    },
    'delivery_address': 'Barrio La Virginia, casa verde',
    'delivery_latitude': '10.13978',
    'delivery_longitude': '-85.44389',
  };
  
  // Datos del repartidor de ejemplo
  final Map<String, dynamic> sampleDriverData = {
    'first_name': 'Akion',
    'last_name1': 'Cheng',
    'current_latitude': '10.15749',
    'current_longitude': '-85.44926',
  };
  @override
  void initState() {
    super.initState();
    
    // Inicializar los datos del repartidor y la orden activa
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Provider.of<TestDriverController>(context, listen: false);
      controller.setDriverData(sampleDriverData);
      controller.setActiveOrders([sampleOrder]);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<TestDriverController>(
        builder: (context, controller, child) {
          if (controller.currentDriverData == null) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return ImprovedOrderTrackingWidget(
            controller: controller,
            activeOrder: sampleOrder,
          );
        },
      ),
    );
  }
}
