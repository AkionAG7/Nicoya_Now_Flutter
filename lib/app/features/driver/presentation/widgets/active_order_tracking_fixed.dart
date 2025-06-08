import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:nicoya_now/app/features/driver/presentation/controllers/driver_controller.dart';
import 'package:nicoya_now/app/features/driver/data/driver_order_service.dart';

class ActiveOrderTrackingWidget extends StatefulWidget {
  final DriverController controller;
  final Map<String, dynamic> activeOrder;

  const ActiveOrderTrackingWidget({
    super.key,
    required this.controller,
    required this.activeOrder,
  });

  @override
  State<ActiveOrderTrackingWidget> createState() =>
      _ActiveOrderTrackingWidgetState();
}

class _ActiveOrderTrackingWidgetState extends State<ActiveOrderTrackingWidget> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  int currentStep = 1; // 1: Assigned, 2: Picked up, 3: On the way, 4: Delivered
  Timer? _timer;

  // Initial locations
  late LatLng _driverLocation;
  late LatLng _merchantLocation;
  late LatLng _customerLocation;

  @override
  void initState() {
    super.initState();
    _initLocations();
    _updateCurrentStep();

    // Auto-advance step simulation for demo purposes
    _timer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _advanceStep();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _initLocations() {
    // In a real app, these would come from your database or location service
    final driverData = widget.controller.currentDriverData;
    final orderData = widget.activeOrder;

    // Driver location (should come from driver's actual GPS)
    _driverLocation = LatLng(
      driverData?['current_latitude'] ?? 10.15749,
      driverData?['current_longitude'] ?? -85.44926,
    );

    // Merchant location (from database)
    _merchantLocation = LatLng(
      orderData['merchant']?['latitude'] ?? 10.14353,
      orderData['merchant']?['longitude'] ?? -85.45195,
    );

    // Customer location (delivery address)
    _customerLocation = LatLng(
      orderData['delivery_lat'] ?? 10.13978,
      orderData['delivery_lng'] ?? -85.44389,
    );

    _updateMarkers();
  }

  void _updateCurrentStep() {
    final status = widget.activeOrder['status']?.toString() ?? '';

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
      }
    });
  }

  void _advanceStep() {
    // This is just for demo purposes
    if (currentStep < 4) {
      setState(() {
        currentStep++;
      });
      // Update order status in database based on current step
      String newStatus;
      switch (currentStep) {
        case 2: // Skip this step since picked_up doesn't exist
          newStatus = 'on_way'; // Go directly to on_way
          break;
        case 3:
          newStatus = 'on_way';
          break;
        case 4:
          newStatus = 'delivered';
          break;
        default:
          newStatus = 'in_process';
      }

      widget.controller.updateOrderStatus(
        widget.activeOrder['order_id'],
        newStatus,
      );
    }
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
          ),
          infoWindow: InfoWindow(
            title:
                widget.activeOrder['merchantName'] ?? 'Comercio',
          ),
        ),
      );

      // Customer marker
      _markers.add(
        Marker(
          markerId: const MarkerId('customer'),
          position: _customerLocation,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: widget.activeOrder['customerName'] ?? 'Cliente',
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

        // Top status panel
        Positioned(
          top: 65,
          left: 20,
          right: 20,
          child: _buildStatusPanel(timeRange),
        ),

        // Bottom delivery info with draggable functionality
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

          // Progress steps with icons
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

  Widget _buildDraggableInfoPanel() {
    final String orderId = widget.activeOrder['order_id']?.toString() ?? '';
    
    // Use the preprocessed fields if available
    final String merchantName = widget.activeOrder['merchantName'] ?? 
        widget.activeOrder['merchant']?['business_name']?.toString() ?? 'Comercio';
    final String customerName = widget.activeOrder['customerName'] ?? 
        widget.activeOrder['customer']?['first_name']?.toString() ?? 'Cliente';
    
    // Extract delivery address with safe type handling
    final dynamic deliveryAddressData = widget.activeOrder['delivery_address'];
    String deliveryStreet = '';
    String deliveryCity = '';
    
    if (deliveryAddressData is Map) {
      // If it's a map, try to get the street and district fields
      deliveryStreet = deliveryAddressData['street']?.toString() ?? '';
      deliveryCity = deliveryAddressData['district']?.toString() ?? '';
    }
    
    final String address = '$deliveryStreet $deliveryCity'.trim().isEmpty
        ? 'Dirección de entrega' : '$deliveryStreet $deliveryCity';
    
    final String orderStatus = _getStatusTitle();
    final driverData = widget.controller.currentDriverData;
    final String driverName = 
        "${driverData?['first_name'] ?? ''} ${driverData?['last_name1'] ?? ''}";
        
    return DraggableScrollableSheet(
      initialChildSize: 0.35,
      minChildSize: 0.25,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
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
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              // Handle bar at top
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),
              
              // Driver info header with status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: Color(0xFFE60023),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: Color(0xFFE60023)),
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
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        orderStatus,
                        style: const TextStyle(
                          color: Color(0xFFE60023),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Order details section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order ID
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Pedido #${orderId.substring(0, orderId.length > 8 ? 8 : orderId.length)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Pickup location
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.green.withAlpha(51),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.store,
                            color: Colors.green,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Recoger en",
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                              Text(
                                merchantName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Delivery location
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red.withAlpha(51),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Entregar a",
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                              Text(
                                customerName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                address,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Action buttons based on status
                    if (widget.activeOrder['status'] == 'on_way')
                      ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            await DriverOrderService.markDelivered(orderId);
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Pedido entregado correctamente')),
                            );
                            await widget.controller.loadActiveOrders();
                            _updateCurrentStep();
                          } catch (e) {
                            debugPrint('Error al marcar como entregado: $e');
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Error al marcar como entregado'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Marcar como entregado'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE60023),
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(50),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    
                    // Action buttons for other statuses
                    if (widget.activeOrder['status'] != 'on_way')
                      Row(
                        children: _buildActionButtonsForStatus(orderId),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildActionButtonsForStatus(String orderId) {
    final String status = widget.activeOrder['status']?.toString() ?? 'assigned';

    switch (status) {
      case 'in_process':
      case 'assigned':
      case 'pending':
      case 'accepted':
        return [
          _buildActionButton(
            icon: Icons.call,
            label: 'Llamar',
            color: Colors.blue,
            onTap: () {
              // Implementation for calling
            },
          ),
          _buildActionButton(
            icon: Icons.local_shipping,
            label: 'En Camino',
            color: const Color(0xFFE60023),
            onTap: () async {
              await widget.controller.updateOrderStatus(orderId, 'on_way');
              _updateCurrentStep();
            },
          ),
        ];
      case 'delivered':
      default:
        return [
          _buildActionButton(
            icon: Icons.star,
            label: 'Calificar',
            color: Colors.amber,
            onTap: () {
              // Implementation for rating
            },
          ),
          _buildActionButton(
            icon: Icons.check_circle,
            label: 'Finalizar',
            color: Colors.green,
            onTap: () {
              // Return to home or show summary
              Navigator.pop(context);
            },
          ),
        ];
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ElevatedButton.icon(
          icon: Icon(icon, size: 18),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          onPressed: onTap,
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return GestureDetector(
      onTap: () {
        // Return to previous screen
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
  }
  
  String _getStatusTitle() {
    switch (currentStep) {
      case 1:
        final status = widget.activeOrder['status']?.toString() ?? '';
        if (status == 'in_process') {
          return 'Disponible';
        } else {
          return 'Pedido aceptado';
        }
      case 2:
        return 'En preparación';
      case 3:
        return 'En camino';
      case 4:
        return 'Entregado';
      default:
        return 'En proceso';
    }
  }
}
