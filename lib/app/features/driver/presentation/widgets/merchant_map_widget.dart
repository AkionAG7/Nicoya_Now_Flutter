import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MerchantMapWidget extends StatefulWidget {
  final LatLng? driverLocation;

  const MerchantMapWidget({
    Key? key,
    this.driverLocation,
  }) : super(key: key);

  @override
  State<MerchantMapWidget> createState() => _MerchantMapWidgetState();
}

class _MerchantMapWidgetState extends State<MerchantMapWidget> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  
  // Default to Nicoya center if driver location isn't provided
  late LatLng _centerLocation;

  @override
  void initState() {
    super.initState();
    _centerLocation = widget.driverLocation ?? const LatLng(10.15749, -85.44926);
    _loadMerchantLocations();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadMerchantLocations() async {
    try {
      final supabase = Supabase.instance.client;
      
      // Fetch merchant locations from database
      final response = await supabase
          .from('merchant')
          .select('merchant_id, business_name, latitude, longitude')
          .eq('is_active', true);
      
      // Add driver marker if location available
      if (widget.driverLocation != null) {
        _markers.add(Marker(
          markerId: const MarkerId('driver'),
          position: widget.driverLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Mi ubicación'),
        ));
      }
      
      // Add merchant markers from response
      for (final merchant in response) {
        if (merchant['latitude'] != null && merchant['longitude'] != null) {
          final location = LatLng(
            double.parse(merchant['latitude'].toString()),
            double.parse(merchant['longitude'].toString()),
          );
          
          _markers.add(Marker(
            markerId: MarkerId('merchant_${merchant['merchant_id']}'),
            position: location,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            infoWindow: InfoWindow(title: merchant['business_name'] ?? 'Comercio'),
          ));
        }
      }
      
      // If no merchants found or no locations available, add sample data
      if (_markers.length <= 1) { // Only driver marker or empty
        _addSampleMerchants();
      }
      
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error loading merchant locations: $e');
      // Add sample data on error
      _addSampleMerchants();
      if (mounted) {
        setState(() {});
      }
    }
  }
  
  void _addSampleMerchants() {
    final sampleLocations = [
      {'id': '1', 'name': 'Restaurante El Parque', 'location': const LatLng(10.14353, -85.45195)},
      {'id': '2', 'name': 'Cafetería Sabor Tico', 'location': const LatLng(10.13978, -85.44389)},
      {'id': '3', 'name': 'Soda La Esquina', 'location': const LatLng(10.15020, -85.45400)},
    ];
    
    for (final merchant in sampleLocations) {
      _markers.add(Marker(
        markerId: MarkerId('sample_${merchant['id']}'),
        position: merchant['location'] as LatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: merchant['name'] as String),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _centerLocation,
          zoom: 14,
        ),
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
        onMapCreated: (controller) {
          _mapController = controller;
        },
      ),
    );
  }
}
