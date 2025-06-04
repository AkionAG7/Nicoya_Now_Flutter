import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nicoya_now/app/core/constants/map_constants.dart';

class MerchantMapWidget extends StatefulWidget {
  final LatLng? driverLocation;

  const MerchantMapWidget({
    super.key,
    this.driverLocation,
  });

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
    _centerLocation = widget.driverLocation ?? 
      const LatLng(MapConstants.defaultLatitude, MapConstants.defaultLongitude);
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
      // First try with address field which might contain coordinates
      try {
        final response = await supabase
            .from('merchant')
            .select('merchant_id, business_name, address')
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
         //ignore: avoid_print
        print('Merchants found: ${response.length}');
        
        // For now, add sample merchants instead of trying to parse addresses
        // In a production app, you would need address geocoding
        _addSampleMerchants();
        
      } catch (e) {
         //ignore: avoid_print
        print('Error with first merchant query approach: $e');
        
        // Fallback option if the first query fails - try with a different schema
        try {
          final responseFallback = await supabase
              .from('merchant')
              .select('merchant_id, business_name')
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
          
          // Add sample merchant markers since we don't have location data
          _addSampleMerchants();
          
        } catch (e2) {
           //ignore: avoid_print
          print('Error with fallback merchant query: $e2');
          rethrow;
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
       //ignore: avoid_print
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
