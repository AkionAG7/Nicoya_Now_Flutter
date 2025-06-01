import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Clase utilitaria para realizar diagnósticos sobre órdenes específicas
class OrderDiagnosticUtils {
  final SupabaseClient _supabase;
  
  // ID de la orden problemática que se está diagnosticando
  static const String problematicOrderId = 'f50a1fbb-d76b-4c0e-af0e-d20015396591';
  
  OrderDiagnosticUtils({required SupabaseClient supabase}) : _supabase = supabase;
  
  /// Verificar si la orden existe en la tabla principal de órdenes
  Future<Map<String, dynamic>?> checkOrderExistenceInMainTable(String orderId) async {
    try {
      final orderResponse = await _supabase
          .from('order')
          .select('order_id, status')
          .eq('order_id', orderId)
          .maybeSingle();
      
      if (orderResponse != null) {
        print('DEBUG: Orden encontrada en la tabla de órdenes:');
        print('DEBUG: ID de Orden: ${orderResponse['order_id']}');
        print('DEBUG: Estado de Orden: ${orderResponse['status']}');
        return orderResponse;
      } else {
        print('DEBUG: Orden específica no encontrada en la tabla de órdenes');
        return await _tryMinimalOrderQuery(orderId);
      }
    } catch (e) {
      print('ERROR verificando tabla de órdenes: $e');
      return await _tryMinimalOrderQuery(orderId);
    }
  }
  
  /// Intenta una consulta mínima como alternativa
  Future<Map<String, dynamic>?> _tryMinimalOrderQuery(String orderId) async {
    try {
      final rawOrderResponse = await _supabase
          .from('order')
          .select('order_id')
          .eq('order_id', orderId)
          .maybeSingle();
      
      if (rawOrderResponse != null) {
        print('DEBUG: La orden existe en la tabla (consulta mínima)');
        return rawOrderResponse;
      } else {
        print('DEBUG: La orden definitivamente no existe');
        return null;
      }
    } catch (e) {
      print('ERROR con consulta mínima de orden: $e');
      return null;
    }
  }
  
  /// Verificar asignación de orden para un conductor específico
  Future<Map<String, dynamic>?> checkOrderAssignment(String orderId, String userId) async {
    try {
      final assignmentResponse = await _supabase
          .from('order_assignment')
          .select('order_id, driver_id, assigned_at')
          .eq('order_id', orderId)
          .eq('driver_id', userId)
          .maybeSingle();
      
      if (assignmentResponse != null) {
        print('DEBUG: Asignación encontrada para orden específica:');
        print(assignmentResponse);
        return assignmentResponse;
      } else {
        print('DEBUG: No se encontró asignación para esta orden para este conductor');
        return await checkAnyDriversAssignment(orderId);
      }
    } catch (e) {
      print('ERROR verificando asignaciones: $e');
      return null;
    }
  }
  
  /// Verificar si cualquier conductor está asignado a la orden
  Future<Map<String, dynamic>?> checkAnyDriversAssignment(String orderId) async {
    try {
      final anyAssignmentResponse = await _supabase
          .from('order_assignment')
          .select('order_id, driver_id, assigned_at')
          .eq('order_id', orderId)
          .maybeSingle();
      
      if (anyAssignmentResponse != null) {
        print('DEBUG: Se encontró asignación para otro conductor:');
        print('DEBUG: ID de Conductor: ${anyAssignmentResponse['driver_id']}');
        return anyAssignmentResponse;
      } else {
        print('DEBUG: No se encontró asignación para esta orden para ningún conductor');
        return null;
      }
    } catch (e) {
      print('ERROR verificando asignación de cualquier conductor: $e');
      return null;
    }
  }
  
  /// Verificar si la orden aparece en la vista
  Future<Map<String, dynamic>?> checkOrderInView(String orderId) async {
    try {
      final viewResponse = await _supabase
          .from('current_driver_orders')
          .select('order_id, status')
          .eq('order_id', orderId)
          .maybeSingle();
      
      if (viewResponse != null) {
        print('DEBUG: Orden encontrada en la vista current_driver_orders:');
        print(viewResponse);
        return viewResponse;
      } else {
        print('DEBUG: Orden no encontrada en la vista current_driver_orders');
        await checkSampleOrdersInView();
        return null;
      }
    } catch (e) {
      print('ERROR verificando vista: $e');
      await verifyViewExists();
      return null;
    }
  }
  
  /// Verificar una muestra de órdenes en la vista
  Future<List<Map<String, dynamic>>> checkSampleOrdersInView() async {
    try {
      final allDriverOrders = await _supabase
          .from('current_driver_orders')
          .select('order_id, status')
          .limit(10);
      
      print('DEBUG: Primeras 10 órdenes en la vista:');
      for (var order in allDriverOrders) {
        print('ID de Orden: ${order['order_id']}, Estado: ${order['status']}');
      }
      
      return List<Map<String, dynamic>>.from(allDriverOrders);
    } catch (e) {
      print('ERROR recuperando muestra de órdenes: $e');
      return [];
    }
  }
  
  /// Verificar si la vista existe y es accesible
  Future<bool> verifyViewExists() async {
    try {
      final simpleViewResponse = await _supabase
          .from('current_driver_orders')
          .select('order_id')
          .limit(1);
      
      print('DEBUG: La consulta simple de vista tuvo éxito, encontró ${simpleViewResponse.length} filas');
      return true;
    } catch (e) {
      print('ERROR con consulta simple de vista: $e');
      print('DEBUG: La vista puede no estar configurada correctamente');
      return false;
    }
  }
  
  /// Ejecutar un diagnóstico completo de la orden
  Future<void> runFullDiagnostic(String orderId, String userId) async {
    print('\n=== INICIANDO DIAGNÓSTICO COMPLETO PARA ORDEN: $orderId ===');
    
    // Verificar existencia en la tabla principal
    final orderExists = await checkOrderExistenceInMainTable(orderId);
    print('Orden existe en tabla principal: ${orderExists != null}');
    
    // Verificar asignación para este conductor
    final hasAssignment = await checkOrderAssignment(orderId, userId);
    print('Orden tiene asignación para este conductor: ${hasAssignment != null}');
    
    // Verificar existencia en la vista
    final inView = await checkOrderInView(orderId);
    print('Orden existe en la vista: ${inView != null}');
    
    print('=== FIN DEL DIAGNÓSTICO PARA ORDEN: $orderId ===\n');
  }
}
