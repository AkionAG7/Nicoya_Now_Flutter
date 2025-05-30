import 'package:flutter/material.dart';
import 'package:nicoya_now/app/features/ubication/delivery_tracking/ubication_controller.dart';

final ubicacionController = UbicacionController();

void pedirPermisoUbicacion(BuildContext context) async {
  final permiso = await showDialog<bool>(
    context: context,
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

  // Si el usuario aceptó, ahora sí pedimos los permisos reales
  if (permiso == true) {
    final ubicacion = await ubicacionController.obtenerUbicacion();
    if (ubicacion != null) {
      // Ubicación obtenida
      print("Ubicación: ${ubicacion.latitude}, ${ubicacion.longitude}");
    } else {
      // No se pudo obtener la ubicación
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se pudo obtener la ubicación.")),
      );
    }
  }
}
