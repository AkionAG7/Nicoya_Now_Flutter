// lib/controllers/ubicacion_controller.dart
import 'package:location/location.dart';

class UbicacionController {
  final Location _location = Location();

  /// Check if location permissions are already granted
  Future<bool> tienePermisos() async {
    bool servicioActivo = await _location.serviceEnabled();
    PermissionStatus permisos = await _location.hasPermission();
    
    return servicioActivo && permisos == PermissionStatus.granted;
  }

  Future<LocationData?> obtenerUbicacion() async {
    bool servicioActivo = await _location.serviceEnabled();
    if (!servicioActivo) {
      servicioActivo = await _location.requestService();
      if (!servicioActivo) return null;
    }

    PermissionStatus permisos = await _location.hasPermission();
    if (permisos == PermissionStatus.denied) {
      permisos = await _location.requestPermission();
      if (permisos != PermissionStatus.granted) return null;
    }

    return await _location.getLocation();
  }

  Stream<LocationData> escucharUbicacion() {
    return _location.onLocationChanged;
  }
}
