import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:nicoya_now/app/features/driver/presentation/controllers/driver_controller.dart';
import 'package:nicoya_now/app/features/driver/data/driver_order_service.dart';

class ImprovedOrderTrackingWidget extends StatefulWidget {
  final DriverController controller;
  final Map<String, dynamic> activeOrder;

  const ImprovedOrderTrackingWidget({
    super.key,
    required this.controller,
    required this.activeOrder,
  });

  @override
  State<ImprovedOrderTrackingWidget> createState() =>
      _ImprovedOrderTrackingWidgetState();
}

class _ImprovedOrderTrackingWidgetState
    extends State<ImprovedOrderTrackingWidget> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  int currentStep = 1; // 1: Assigned, 2: Picked up, 3: On the way, 4: Delivered

  // Initial locations
  late LatLng _driverLocation;
  late LatLng _merchantLocation;
  late LatLng _customerLocation;  @override
  void initState() {
    super.initState();
    
    // Asserts for debugging
    assert(widget.activeOrder['merchant'] is Map<String, dynamic>, 'Merchant debe ser un Map<String, dynamic>');
    assert(widget.activeOrder['customer'] is Map<String, dynamic>, 'Customer debe ser un Map<String, dynamic>');
    assert(widget.activeOrder['delivery_address'] != null, 'Delivery address no debe ser null');
    
    _initLocations();
    _updateCurrentStep();
    
    // Registro para ayudar a la depuración
    print('ImprovedOrderTrackingWidget inicializado con pedido: ${widget.activeOrder['order_id']}');
    print('Estado del pedido: ${widget.activeOrder['status']}');
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
      double.parse(driverData?['current_longitude']?.toString() ?? '-85.44926'),
    );

    // Merchant location
    _merchantLocation = LatLng(
      double.parse(
        orderData['merchant']?['latitude']?.toString() ?? '10.14353',
      ),
      double.parse(
        orderData['merchant']?['longitude']?.toString() ?? '-85.45195',
      ),
    );

    // Customer location
    _customerLocation = LatLng(
      double.parse(orderData['delivery_latitude']?.toString() ?? '10.13978'),
      double.parse(orderData['delivery_longitude']?.toString() ?? '-85.44389'),
    );

    _updateMarkers();
  }  void _updateCurrentStep() {
    final status = widget.activeOrder['status']?.toString() ?? '';
    
    print('Actualizando paso de seguimiento basado en status: $status');

    setState(() {
      switch (status) {
        case 'assigned':
          currentStep = 1;
          break;
        case 'pending':
          currentStep = 1;
          break;
        case 'accepted':
          currentStep = 1;
          break;
        case 'in_process':
          currentStep = 1;
          break;
        case 'on_way':
          currentStep = 3;
          break;
        case 'delivered':
          currentStep = 4;
          break;
        default:
          currentStep = 1;
          print('Estado no reconocido: $status, configurando paso 1');
      }
    });
  }

  void _updateMarkers() {
    setState(() {
      _markers.clear();

      // Driver marker
      _markers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: _driverLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Mi ubicación'),
        ),
      );

      // Merchant marker
      _markers.add(
        Marker(
          markerId: const MarkerId('merchant'),
          position: _merchantLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),          infoWindow: InfoWindow(
            title:
                widget.activeOrder['merchant']?['business_name']?.toString() ?? 'Comercio',
          ),
        ),
      );

      // Customer marker
      _markers.add(
        Marker(
          markerId: const MarkerId('customer'),
          position: _customerLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),          infoWindow: InfoWindow(
            title: widget.activeOrder['customer']?['name']?.toString() ?? 'Cliente',
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get estimated time range
    final now = DateTime.now();
    final deliveryEndTime = now.add(const Duration(minutes: 45));
    final timeFormat = DateFormat('h:mm a');
    final String timeRange =
        "${timeFormat.format(now)} - ${timeFormat.format(deliveryEndTime)}";

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
        
        // Bottom driver info panel with draggable functionality
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildDraggableInfoPanel(),
        ),

        // Back button
        Positioned(top: 20, left: 16, child: _buildBackButton()),
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
            color: Colors.black.withAlpha(51),
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
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(
            "Tiempo estimado $timeRange",
            style: const TextStyle(color: Colors.grey, fontSize: 11),
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
  }  String _getCustomerAddress() {
    // Extract delivery address with safe type handling
    final dynamic deliveryAddressData = widget.activeOrder['delivery_address'];
    
    if (deliveryAddressData is Map) {
      // If it's a map, try to get the address field or street field
      return deliveryAddressData['address']?.toString() ?? 
             deliveryAddressData['street']?.toString() ??
             'Dirección de entrega';
    } else if (deliveryAddressData is String) {
      // If it's already a string
      return deliveryAddressData;
    } else {
      // Default fallback
      return 'Dirección de entrega';
    }
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
              color: Colors.black.withAlpha(51),
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
  }  Widget _buildActionButtons() {
    final String status = widget.activeOrder['status']?.toString() ?? '';
    final String orderId = widget.activeOrder['order_id']?.toString() ?? '';

    if (status == 'on_way') {
      return Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.check_circle),
              label: const Text('Marcar como entregado'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE60023),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () async {
                // Mostrar diálogo de confirmación
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirmar entrega'),
                    content: const Text('¿Has entregado este pedido al cliente?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Confirmar'),
                      ),
                    ],
                  ),
                );
                  if (confirm == true) {
                  try {
                    // Import the service at the top of the file
                    // import 'package:nicoya_now/app/features/driver/data/driver_order_service.dart';
                    
                    // Mostrar indicador de carga
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Actualizando estado del pedido...'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                    
                    // Usar el nuevo método markDelivered
                    await DriverOrderService.markDelivered(orderId);
                    
                    // Reload active orders to ensure UI is updated
                    await widget.controller.loadActiveOrders();
                    
                    // Actualizar estado local
                    _updateCurrentStep();
                    
                    // Mostrar mensaje de éxito
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('¡Pedido entregado correctamente!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    
                    // Volver a la pantalla principal después de un breve retraso
                    Future.delayed(const Duration(seconds: 2), () {
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    });
                  } catch (e, s) {
                    // Handle any exceptions with more details
                    debugPrint('Error markDelivered → $e\n$s');
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al marcar el pedido como entregado'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildDraggableInfoPanel() {
    final driverData = widget.controller.currentDriverData;
    
    // Extract merchant and customer names properly
    final String merchantName = widget.activeOrder['merchant']?['business_name']?.toString() ?? 'Comercio';
    final String customerName = widget.activeOrder['customer']?['name']?.toString() ?? 'Cliente';
    
    // Get customer address using safe extraction
    final String customerAddress = _getCustomerAddress();
    
    // Format driver name
    final String driverName = "${driverData?['first_name']?.toString() ?? ''} ${driverData?['last_name1']?.toString() ?? ''}";

    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.25,
      maxChildSize: 0.85,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(77),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ListView(
          controller: controller,
          children: [
            // Handle bar at top for drag indication
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),
            
            // Driver info header with red background
            Container(
              padding: const EdgeInsets.all(16),
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
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Order details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Merchant info
                  Text(
                    merchantName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Customer info
                  Text(
                    '$customerName • $customerAddress',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  
                  const Divider(height: 24),
                  
                  // Address section
                  Row(
                    children: const [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 6),
                      Text(
                        "Dirección de entrega",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    customerAddress,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Preparation status
                  Row(
                    children: const [
                      Icon(Icons.access_time, size: 16, color: Colors.grey),
                      SizedBox(width: 6),
                      Text(
                        "Tiempo estimado",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "30 Mins",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  // Add action buttons
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
