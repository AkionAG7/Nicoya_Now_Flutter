import 'package:flutter/material.dart';

/// Clase de utilidad para formatear estados y colores
class StatusFormatter {
  /// Convierte el código de estado en texto legible
  static String formatStatus(String status) {
    switch (status) {
      case 'pending':
        return 'Pendiente'; 
      case 'accepted':
        return 'Aceptado';
      case 'in_process':
        return 'En proceso';
      case 'on_way':
        return 'En camino';
      case 'delivered':
        return 'Entregado';
      case 'cancelled':
        return 'Cancelado';
      default:
        return 'Desconocido';
    }
  }
  
  /// Obtiene el color asociado con un estado
  static Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.grey;
      case 'accepted':
        return Colors.amber;
      case 'in_process':
        return Colors.blue;
      case 'on_way':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Formatea un ID de orden para mostrar solo los primeros caracteres
  static String formatOrderId(String id) {
    if (id.isEmpty) return '';
    return id.substring(0, id.length > 8 ? 8 : id.length);
  }
}
