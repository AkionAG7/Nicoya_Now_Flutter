
import 'package:supabase_flutter/supabase_flutter.dart';

/// Clase utilitaria para diagnóstico y depuración de órdenes activas de conductores
class OrderDebugUtils {
  final SupabaseClient _supabase;
  
  OrderDebugUtils({required SupabaseClient supabase}) : _supabase = supabase;

  /// Verificar asignaciones para un usuario específico
  Future<List<Map<String, dynamic>>> checkDriverAssignments(String userId) async {
    try {
      final assignmentResponse = await _supabase
          .from('order_assignment')
          .select('order_id')
          .eq('driver_id', userId);
      // ignore: avoid_print
      print('DEBUG: Asignaciones encontradas: ${assignmentResponse.length}');
      for (var assignment in assignmentResponse) {
        // ignore: avoid_print
        print('DEBUG: Pedido asignado: ${assignment['order_id']}');
      }
      
      return List<Map<String, dynamic>>.from(assignmentResponse);
    } catch (e) {
      // ignore: avoid_print
      print('ERROR consultando asignaciones: $e');
      return [];
    }
  }

  /// Verificar pedidos en la vista de pedidos del conductor
  Future<List<Map<String, dynamic>>> checkOrdersInView() async {
    try {
      final ordersResponse = await _supabase
          .from('current_driver_orders')
          .select('order_id, status')
          .limit(20);
      // ignore: avoid_print
      print('DEBUG: Pedidos en la vista: ${ordersResponse.length}');
      for (var order in ordersResponse) {
        // ignore: avoid_print
        print('DEBUG: Pedido ${order['order_id']} - Estado: ${order['status']}');
      }
      
      return List<Map<String, dynamic>>.from(ordersResponse);
    } catch (e) {
      // ignore: avoid_print
      print('ERROR consultando la vista: $e');
      return await _checkOrdersInDirectTable();
    }
  }

  /// Realizar consulta directa a la tabla de pedidos como alternativa
  Future<List<Map<String, dynamic>>> _checkOrdersInDirectTable() async {
    try {
      // ignore: avoid_print
      print('DEBUG: Intentando consulta directa a la tabla de pedidos');
      final directOrdersResponse = await _supabase
          .from('order')
          .select('order_id, status')
          .limit(20);
      // ignore: avoid_print
      print('DEBUG: Pedidos en tabla directa: ${directOrdersResponse.length}');
      return List<Map<String, dynamic>>.from(directOrdersResponse);
    } catch (e) {
      // ignore: avoid_print
      print('ERROR consultando tabla directa: $e');
      return [];
    }
  }

  /// Ejecutar diagnóstico completo para un conductor
  Future<void> runFullDriverDiagnostic(String userId, List<Map<String, dynamic>> activeOrders, 
      {required Function() loadActiveOrders, required Function() forceCheckSpecificOrder, 
      required Function() forceUpdateSpecificOrderStatus}) async {
    try {
      // ignore: avoid_print
      print('\n=== INICIANDO DIAGNÓSTICO COMPLETO PARA CONDUCTOR: $userId ===');
      
      // Verificar asignaciones
      // ignore: avoid_print
      print('Verificando asignaciones para el usuario');
      await checkDriverAssignments(userId);
      
      // Verificar vista de pedidos
      // ignore: avoid_print
      print('Verificando pedidos en la vista');
      await checkOrdersInView();
      
      // Ejecutar carga de pedidos activos
      // ignore: avoid_print
      print('Ejecutando carga de pedidos activos');
      try {
        await loadActiveOrders();
      } catch (e) {
        // ignore: avoid_print
        print('ERROR cargando pedidos activos: $e');
      }
      
      // Verificación forzada del pedido específico
      // ignore: avoid_print
      print('Ejecutando verificación forzada de pedido específico');
      try {
        // Primero actualizar el estado si es necesario
        await forceUpdateSpecificOrderStatus();
        
        // Luego verificar el pedido
        await forceCheckSpecificOrder();
      } catch (e) {
        // ignore: avoid_print
        print('ERROR en verificación forzada: $e');
      }
      
      // Verificar pedidos cargados
      // ignore: avoid_print
      print('DEBUG: Pedidos cargados después del diagnóstico: ${activeOrders.length}');
      for (var order in activeOrders) {
        // ignore: avoid_print
        print('DEBUG: Pedido activo ${order['order_id']} - Estado: ${order['status']}');
      }
      // ignore: avoid_print
      print('=== FIN DEL DIAGNÓSTICO PARA CONDUCTOR: $userId ===\n');
    } catch (e) {
      // ignore: avoid_print
      print('ERROR en diagnóstico de órdenes: $e');
    }
  }
}
