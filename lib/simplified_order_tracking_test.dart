import 'package:flutter/material.dart';

// Importamos las dependencias necesarias
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:nicoya_now/app/core/constants/map_constants.dart';

// Creamos un archivo de prueba simplificado que no dependa del DriverController

void main() {
  runApp(const OrderTrackingTestApp());
}

class OrderTrackingTestApp extends StatelessWidget {
  const OrderTrackingTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OrderTrackingTestPage(),
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

  // Para simular el progreso de la entrega
  int currentStep = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SimplifiedTrackingWidget(
        driverData: sampleDriverData,
        orderData: sampleOrder,
        currentStep: currentStep,
        onStepChanged: (step) {
          setState(() {
            currentStep = step;
          });
        },
      ),
    );
  }
}

class SimplifiedTrackingWidget extends StatefulWidget {
  final Map<String, dynamic> driverData;
  final Map<String, dynamic> orderData;
  final int currentStep;
  final Function(int) onStepChanged;
  
  const SimplifiedTrackingWidget({
    Key? key,
    required this.driverData,
    required this.orderData,
    required this.currentStep,
    required this.onStepChanged,
  }) : super(key: key);

  @override
  State<SimplifiedTrackingWidget> createState() => _SimplifiedTrackingWidgetState();
}

class _SimplifiedTrackingWidgetState extends State<SimplifiedTrackingWidget> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  // Initial locations
  late LatLng _driverLocation;
  late LatLng _merchantLocation;
  late LatLng _customerLocation;

  @override
  void initState() {
    super.initState();
    _initLocations();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _initLocations() {
    // Get locations from driver and order data
    final driverData = widget.driverData;
    final orderData = widget.orderData;
    
    // Driver location (actual GPS)
    _driverLocation = LatLng(
      double.parse(driverData['current_latitude'].toString()),
      double.parse(driverData['current_longitude'].toString())
    );
    
    // Merchant location
    _merchantLocation = LatLng(
      double.parse(orderData['merchant']['latitude'].toString()),
      double.parse(orderData['merchant']['longitude'].toString())
    );
    
    // Customer location
    _customerLocation = LatLng(
      double.parse(orderData['delivery_latitude'].toString()),
      double.parse(orderData['delivery_longitude'].toString())
    );
    
    _updateMarkers();
  }
    void _updateMarkers() {
    setState(() {
      _markers.clear();
      
      // Driver marker
      _markers.add(Marker(
        markerId: const MarkerId('driver'),
        position: _driverLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Mi ubicación'),
      ));
      
      // Merchant marker
      _markers.add(Marker(
        markerId: const MarkerId('merchant'),
        position: _merchantLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: widget.orderData['merchant']['business_name']),
      ));
      
      // Customer marker
      _markers.add(Marker(
        markerId: const MarkerId('customer'),
        position: _customerLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: widget.orderData['customer']['name']),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get estimated time range
    final now = DateTime.now();
    final deliveryEndTime = now.add(const Duration(minutes: 45));
    final timeFormat = DateFormat('h:mm a');
    final String timeRange = "${timeFormat.format(now)} - ${timeFormat.format(deliveryEndTime)}";
    
    return Stack(
      children: [
        // Map covering the whole background
        SizedBox(
          height: MediaQuery.of(context).size.height,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _driverLocation,
              zoom: 14,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),
        ),
        
        // Top status panel - similar to the image
        Positioned(
          top: 65,
          left: 20,
          right: 20,
          child: _buildStatusPanel(timeRange),
        ),
        
        // Bottom driver info panel - similar to the image
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildDriverInfoPanel(),
        ),
        
        // Back button
        Positioned(
          top: 20,
          left: 16,
          child: _buildBackButton(),
        ),
      ],
    );
  }
  
  Widget _buildStatusPanel(String timeRange) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tu tiempo de envío",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            "Tiempo estimado $timeRange",
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          
          // Progress steps with icons - similar to the image
          Row(
            children: [
              _buildIconStep(Icons.assignment, 1),
              _buildDashedLine(widget.currentStep >= 2),
              _buildIconStep(Icons.restaurant, 2),
              _buildDashedLine(widget.currentStep >= 3),
              _buildIconStep(Icons.delivery_dining, 3),
              _buildDashedLine(widget.currentStep >= 4),
              _buildIconStep(Icons.check_circle_outline, 4),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildIconStep(IconData icon, int step) {
    return Icon(
      icon,
      color: widget.currentStep >= step ? const Color(0xFFE60023) : Colors.grey,
      size: 28,
    );
  }
  
  Widget _buildDashedLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE60023) : Colors.grey,
        ),
      ),
    );
  }
  
  Widget _buildDriverInfoPanel() {
    final String driverName = "${widget.driverData['first_name']} ${widget.driverData['last_name1']}";
    final String address = widget.orderData['merchant']['address'] ?? '25 mts del Liceo de Nicoya';
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Driver info header with red background
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFE60023),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white,
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFFE60023),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driverName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const Text(
                      "Repartidor",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // White part with address and preparation status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Address section
                Row(
                  children: const [
                    Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                    SizedBox(width: 6),
                    Text(
                      "Address",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  address,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Divider(height: 20),
                
                // Preparation status
                Row(
                  children: const [
                    Icon(Icons.access_time, size: 16, color: Colors.grey),
                    SizedBox(width: 6),
                    Text(
                      "Preparando",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "30 Mins",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                // Action buttons for different steps
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon: Icons.call,
                      label: "Llamar",
                      color: Colors.blue,
                      onTap: () {
                        // Implementar llamada
                      },
                    ),
                    _buildActionButton(
                      icon: widget.currentStep < 4 ? Icons.arrow_forward : Icons.check_circle,
                      label: widget.currentStep < 4 ? "Siguiente" : "Finalizar",
                      color: const Color(0xFFE60023),
                      onTap: () {
                        if (widget.currentStep < 4) {
                          widget.onStepChanged(widget.currentStep + 1);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton.icon(
          icon: Icon(icon, size: 18),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
          ),
          onPressed: onTap,
        ),
      ),
    );
  }
  
  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Color(0xFFE60023),
          size: 20,
        ),
      ),
    );
  }
}
