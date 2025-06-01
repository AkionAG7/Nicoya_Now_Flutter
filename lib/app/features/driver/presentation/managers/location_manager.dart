import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nicoya_now/app/features/ubication/delivery_tracking/ubication_controller.dart';
import 'package:nicoya_now/app/features/driver/presentation/controllers/driver_controller.dart';

class LocationManager {
  final UbicacionController ubicacionController = UbicacionController();
  StreamSubscription? _locationSubscription;
  Function(double, double)? _onLocationUpdate;
  BuildContext? _context;
  DriverController? _controller;

  void init(BuildContext context, DriverController controller) {
    _context = context;
    _controller = controller;
  }

  Future<void> requestLocationPermissions() async {
    try {
      final permiso = await showDialog<bool>(
        context: _context!,
        builder: (context) {
          return AlertDialog(
            title: const Text("Permiso de Ubicación"),
            content: const Text(
              "¿Quieres permitir que esta app acceda a tu ubicación para brindarte un mejor servicio?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Permitir"),
              ),
            ],
          );
        },
      );

      if (permiso == true) {
        await updateLocation();
      }
    } catch (e) {
      print("Error initializing location: $e");
    }
  }

  void startLocationUpdates(Function(double, double) onLocationUpdate) {
    _onLocationUpdate = onLocationUpdate;
    _locationSubscription = ubicacionController.escucharUbicacion().listen((ubicacion) {
      if (ubicacion.latitude != null && ubicacion.longitude != null) {
        // Update driver location in database
        _controller?.updateLocation(ubicacion.latitude!, ubicacion.longitude!);
        
        // Notify the callback
        _onLocationUpdate?.call(ubicacion.latitude!, ubicacion.longitude!);
      }
    });
  }

  Future<void> updateLocation() async {
    try {
      final ubicacion = await ubicacionController.obtenerUbicacion();
      if (ubicacion != null && ubicacion.latitude != null && ubicacion.longitude != null) {
        print("Ubicación obtenida: ${ubicacion.latitude}, ${ubicacion.longitude}");
        
        // Update driver location in database
        _controller?.updateLocation(ubicacion.latitude!, ubicacion.longitude!);
        
        // Notify the callback
        _onLocationUpdate?.call(ubicacion.latitude!, ubicacion.longitude!);
      } else {
        print("No se pudo obtener la ubicación");
      }
    } catch (e) {
      print("Error updating location: $e");
    }
  }

  void dispose() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
    _onLocationUpdate = null;
    _context = null;
    _controller = null;
  }
}
