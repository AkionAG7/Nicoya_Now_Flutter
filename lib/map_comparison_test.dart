import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Widget de prueba para comparar el comportamiento del mapa
/// Este mapa replica exactamente la configuración del merchant map que funciona bien
class MapComparisonTest extends StatefulWidget {
  const MapComparisonTest({super.key});

  @override
  State<MapComparisonTest> createState() => _MapComparisonTestState();
}

class _MapComparisonTestState extends State<MapComparisonTest> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  late LatLng _centerLocation;

  @override
  void initState() {
    super.initState();
    _centerLocation = const LatLng(10.15749, -85.44926); // Nicoya center
    _addSampleMarkers();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _addSampleMarkers() {
    _markers.add(
      const Marker(
        markerId: MarkerId('driver'),
        position: LatLng(10.15749, -85.44926),
        infoWindow: InfoWindow(title: 'Mi ubicación'),
      ),
    );
    
    _markers.add(
      const Marker(
        markerId: MarkerId('merchant'),
        position: LatLng(10.14353, -85.45195),
        infoWindow: InfoWindow(title: 'Restaurante'),
      ),
    );
    
    _markers.add(
      const Marker(
        markerId: MarkerId('customer'),
        position: LatLng(10.13978, -85.44389),
        infoWindow: InfoWindow(title: 'Cliente'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prueba: Mapa Simple'),
        backgroundColor: const Color(0xFFE60023),
        foregroundColor: Colors.white,
      ),
      body: ClipRRect(
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
          // CRÍTICO: Habilitar TODOS los gestos de mapa para movimiento libre
          scrollGesturesEnabled: true,   // CRÍTICO: permite desplazamiento
          zoomGesturesEnabled: true,     // Zoom con pellizco
          tiltGesturesEnabled: true,     // Inclinar perspectiva
          rotateGesturesEnabled: true,   // Rotar mapa
          compassEnabled: true,          // Mostrar brújula
          mapToolbarEnabled: true,       // Herramientas de navegación
          onMapCreated: (controller) {
            _mapController = controller;
            print('DEBUG: Mapa de prueba creado - configuración igual a merchant map');
          },
          onCameraMoveStarted: () {
            print('DEBUG: [PRUEBA] Usuario comenzó a mover la cámara');
          },
          onCameraMove: (position) {
            print('DEBUG: [PRUEBA] Cámara moviéndose - Lat: ${position.target.latitude}, Lng: ${position.target.longitude}');
          },
          onTap: (position) {
            print('DEBUG: [PRUEBA] Mapa tocado en: $position');
          },
        ),
      ),
    );
  }
}
