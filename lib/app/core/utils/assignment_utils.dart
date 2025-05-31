import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nicoya_now/app/core/utils/uuid_utils.dart';
import 'package:nicoya_now/app/core/utils/rpc_utils.dart';

/// Utilidad para manejar las funciones relacionadas con asignaciones de órdenes
class AssignmentUtils {
  /// Obtiene una asignación por su ID
  static Future<Map<String, dynamic>?> getAssignmentById(
    SupabaseClient supabase, 
    String assignmentId
  ) async {
    if (assignmentId.isEmpty) {
      return null;
    }

    // Asegurarse de que el UUID esté en formato correcto
    final formattedId = UuidUtils.parseUuid(assignmentId);
    
    try {
      // Utilizar la función de RpcUtils para hacer la llamada
      return await RpcUtils.getAssignmentById(supabase, formattedId);
    } catch (e) {
      print('Error al obtener asignación por ID: $e');
      
      // En caso de error, intentar un enfoque alternativo con consultas directas
      try {
        // Consulta directa a la tabla order_assignment
        final result = await supabase
            .from('order_assignment')
            .select('*')
            .eq('assignment_id', formattedId)
            .maybeSingle();
            
        return result;
      } catch (directQueryError) {
        print('Error en consulta directa: $directQueryError');
        return null;
      }
    }
  }

  /// Obtiene una asignación por ID de orden y ID de conductor
  static Future<Map<String, dynamic>?> getAssignmentByOrderAndDriver(
    SupabaseClient supabase, 
    String orderId, 
    String driverId
  ) async {
    if (orderId.isEmpty || driverId.isEmpty) {
      return null;
    }
    
    // Asegurarse de que los UUIDs estén en formato correcto
    final formattedOrderId = UuidUtils.parseUuid(orderId);
    final formattedDriverId = UuidUtils.parseUuid(driverId);
    
    try {
      // Consulta directa a la tabla order_assignment
      final result = await supabase
          .from('order_assignment')
          .select('*')
          .eq('order_id', formattedOrderId)
          .eq('driver_id', formattedDriverId)
          .maybeSingle();
          
      return result;
    } catch (e) {
      print('Error al obtener asignación para orden $orderId y conductor $driverId: $e');
      return null;
    }
  }
  
  /// Crea una nueva asignación
  static Future<bool> createAssignment(
    SupabaseClient supabase, 
    String orderId, 
    String driverId
  ) async {
    if (orderId.isEmpty || driverId.isEmpty) {
      return false;
    }
    
    // Asegurarse de que los UUIDs estén en formato correcto
    final formattedOrderId = UuidUtils.parseUuid(orderId);
    final formattedDriverId = UuidUtils.parseUuid(driverId);
    
    try {
      // Crear registro en la tabla order_assignment
      await supabase
          .from('order_assignment')
          .insert({
            'order_id': formattedOrderId,
            'driver_id': formattedDriverId,
            'assigned_at': DateTime.now().toIso8601String(),
          });
          
      return true;
    } catch (e) {
      print('Error al crear asignación: $e');
      return false;
    }
  }
  
  /// Actualiza una asignación existente
  static Future<bool> updateAssignment(
    SupabaseClient supabase, 
    String orderId, 
    String driverId, 
    Map<String, dynamic> updates
  ) async {
    if (orderId.isEmpty || driverId.isEmpty) {
      return false;
    }
    
    // Asegurarse de que los UUIDs estén en formato correcto
    final formattedOrderId = UuidUtils.parseUuid(orderId);
    final formattedDriverId = UuidUtils.parseUuid(driverId);
    
    try {
      // Actualizar registro en la tabla order_assignment
      await supabase
          .from('order_assignment')
          .update(updates)
          .eq('order_id', formattedOrderId)
          .eq('driver_id', formattedDriverId);
          
      return true;
    } catch (e) {
      print('Error al actualizar asignación: $e');
      return false;
    }
  }
}
