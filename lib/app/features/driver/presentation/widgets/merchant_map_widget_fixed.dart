import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MerchantMapWidget extends StatefulWidget {
  final LatLng? driverLocation;

  const MerchantMapWidget({super.key, this.driverLocation});

  @override
  State<MerchantMapWidget> createState() => _MerchantMapWidgetState();
}

class _MerchantMapWidgetState extends State<MerchantMapWidget> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};

  // Default to Nicoya center if driver location isn't provided
  late LatLng _centerLocation;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _centerLocation =
        widget.driverLocation ?? const LatLng(10.15749, -85.44926);
    _loadMerchantLocations();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  // Simplified merchant loading with graceful error handling
  Future<void> _loadMerchantLocations() async {
    try {
      // Add driver marker if location available
      if (widget.driverLocation != null) {
        _markers.add(
          Marker(
            markerId: const MarkerId('driver'),
            position: widget.driverLocation!,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
            infoWindow: const InfoWindow(title: 'Mi ubicación'),
          ),
        );
      }

      // Always add sample merchants to ensure map has markers
      _addSampleMerchants();

      // Try to fetch actual merchant data if possible
      try {
        final supabase = Supabase.instance.client;

        final response = await supabase
            .from('merchant')
            .select('merchant_id, business_name')
            .eq('is_active', true)
            .limit(10);
        //ignore: avoid_print
        print(
          'Found ${response.length} merchants from database (display using samples)',
        );
      } catch (e) {
        //ignore: avoid_print
        print('Database query for merchants failed: $e');
      }

      if (mounted) {
        setState(() {
          _isLoaded = true;
        });
      }
    } catch (e) {
      //ignore: avoid_print
      print('Error in merchant location loading: $e');
      // Still add sample data on error
      _addSampleMerchants();
      if (mounted) {
        setState(() {
          _isLoaded = true;
        });
      }
    }
  }

  void _addSampleMerchants() {
    final sampleLocations = [
      {
        'id': '1',
        'name': 'Restaurante El Parque',
        'location': const LatLng(10.14353, -85.45195),
      },
      {
        'id': '2',
        'name': 'Cafetería Sabor Tico',
        'location': const LatLng(10.13978, -85.44389),
      },
      {
        'id': '3',
        'name': 'Soda La Esquina',
        'location': const LatLng(10.15020, -85.45400),
      },
    ];

    for (final merchant in sampleLocations) {
      _markers.add(
        Marker(
          markerId: MarkerId('sample_${merchant['id']}'),
          position: merchant['location'] as LatLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: InfoWindow(title: merchant['name'] as String),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _centerLocation,
              zoom: 14,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            // Habilitar TODOS los gestos de mapa para movimiento libre
            scrollGesturesEnabled: true,   // CRÍTICO: permite desplazamiento
            zoomGesturesEnabled: true,     // Zoom con pellizco
            tiltGesturesEnabled: true,     // Inclinar perspectiva
            rotateGesturesEnabled: true,   // Rotar mapa
            compassEnabled: true,          // Mostrar brújula
            mapToolbarEnabled: true,       // Herramientas de navegación
            onMapCreated: (controller) {
              _mapController = controller;
            },
          ),
          if (!_isLoaded) Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
