import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:nicoya_now/app/features/driver/presentation/controllers/driver_controller.dart';

class ImprovedOrderTrackingWidget extends StatefulWidget {
  final DriverController controller;
  final Map<String, dynamic> activeOrder;
  
  const ImprovedOrderTrackingWidget({
    Key? key,
    required this.controller,
    required this.activeOrder,
  }) : super(key: key);

  @override
  State<ImprovedOrderTrackingWidget> createState() => _ImprovedOrderTrackingWidgetState();
}

class _ImprovedOrderTrackingWidgetState extends State<ImprovedOrderTrackingWidget> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  int currentStep = 1; // 1: Assigned, 2: Picked up, 3: On the way, 4: Delivered

  // Initial locations
  late LatLng _driverLocation;
  late LatLng _merchantLocation;
  late LatLng _customerLocation;

  @override
  void initState() {
    super.initState();
    _initLocations();
    _updateCurrentStep();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _initLocations() {
    // Get locations from driver and order data
    final driverData = widget.controller.currentDriverData;
    final orderData = widget.activeOrder;
    
    // Driver location (actual GPS)
    _driverLocation = LatLng(
      double.parse(driverData?['current_latitude']?.toString() ?? '10.15749'), 
      double.parse(driverData?['current_longitude']?.toString() ?? '-85.44926')
    );
    
    // Merchant location
    _merchantLocation = LatLng(
      double.parse(orderData['merchant']?['latitude']?.toString() ?? '10.14353'), 
      double.parse(orderData['merchant']?['longitude']?.toString() ?? '-85.45195')
    );
    
    // Customer location
    _customerLocation = LatLng(
      double.parse(orderData['delivery_latitude']?.toString() ?? '10.13978'), 
      double.parse(orderData['delivery_longitude']?.toString() ?? '-85.44389')
    );
    
    _updateMarkers();
  }
  
  void _updateCurrentStep() {
    final status = widget.activeOrder['status'];
    
    setState(() {
      switch (status) {
        case 'assigned':
          currentStep = 1;
          break;
        case 'picked_up':
          currentStep = 2;
          break;
        case 'on_the_way':
          currentStep = 3;
          break;
        case 'delivered':
          currentStep = 4;
          break;
        default:
          currentStep = 1;
      }
    });
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
        infoWindow: InfoWindow(
          title: widget.activeOrder['merchant']?['business_name'] ?? 'Comercio'
        ),
      ));
      
      // Customer marker
      _markers.add(Marker(
        markerId: const MarkerId('customer'),
        position: _customerLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(
          title: widget.activeOrder['customer']?['name'] ?? 'Cliente'
        ),
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
              _buildDashedLine(currentStep >= 2),
              _buildIconStep(Icons.restaurant, 2),
              _buildDashedLine(currentStep >= 3),
              _buildIconStep(Icons.delivery_dining, 3),
              _buildDashedLine(currentStep >= 4),
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
      color: currentStep >= step ? const Color(0xFFE60023) : Colors.grey,
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
    final driverData = widget.controller.currentDriverData;
    final String driverName = "${driverData?['first_name'] ?? ''} ${driverData?['last_name1'] ?? ''}";
    final String address = widget.activeOrder['merchant']?['address'] ?? '25 mts del Liceo de Nicoya';
    
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
              ],
            ),
          ),
        ],
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
