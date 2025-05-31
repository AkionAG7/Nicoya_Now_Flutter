import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nicoya_now/app/core/utils/assignment_utils.dart';
import 'package:nicoya_now/app/core/utils/rpc_utils.dart';
import 'package:nicoya_now/app/core/utils/uuid_utils.dart';

/// Ejemplo de uso de las utilidades para llamadas a RPC y manejo de UUIDs
class SupabaseRpcExample {
  final SupabaseClient supabase;

  SupabaseRpcExample(this.supabase);

  /// Ejemplo de cómo obtener una asignación por ID
  Future<void> getAssignmentExample(String assignmentId) async {
    try {
      // Uso de la utilidad para obtener una asignación por ID
      final assignment = await AssignmentUtils.getAssignmentById(
        supabase, 
        assignmentId,
      );
      
      if (assignment != null) {
        print('Asignación encontrada:');
        print('Order ID: ${assignment['order_id']}');
        print('Driver ID: ${assignment['driver_id']}');
        print('Assigned at: ${assignment['assigned_at']}');
      } else {
        print('No se encontró la asignación');
      }
    } catch (e) {
      print('Error en ejemplo de asignación: $e');
    }
  }

  /// Ejemplo de cómo hacer una llamada RPC genérica
  Future<void> genericRpcExample(String functionName, Map<String, dynamic> params) async {
    try {
      // Usar RpcUtils para hacer una llamada RPC genérica
      final result = await RpcUtils.callRpcSafely(
        supabase, 
        functionName, 
        params,
      );
      
      print('Resultado de la llamada RPC a $functionName:');
      print(result);
    } catch (e) {
      print('Error en ejemplo de RPC genérica: $e');
    }
  }

  /// Ejemplo de actualización de asignación
  Future<void> updateAssignmentExample(
    String orderId, 
    String driverId, 
    {bool? pickedUp, bool? delivered}
  ) async {
    try {
      // Preparar actualizaciones
      final updates = <String, dynamic>{};
      
      if (pickedUp == true) {
        updates['picked_up_at'] = DateTime.now().toIso8601String();
      }
      
      if (delivered == true) {
        updates['delivered_at'] = DateTime.now().toIso8601String();
      }
      
      if (updates.isNotEmpty) {
        // Usar AssignmentUtils para actualizar la asignación
        final success = await AssignmentUtils.updateAssignment(
          supabase, 
          orderId, 
          driverId, 
          updates,
        );
        
        if (success) {
          print('Asignación actualizada correctamente');
        } else {
          print('Error al actualizar asignación');
        }
      }
    } catch (e) {
      print('Error en ejemplo de actualización: $e');
    }
  }

  /// Ejemplo de cómo crear una nueva asignación
  Future<void> createAssignmentExample(String orderId, String driverId) async {
    try {
      // Asegurarse de que los UUIDs son válidos
      if (!UuidUtils.isValidUuid(orderId) || !UuidUtils.isValidUuid(driverId)) {
        print('IDs inválidos');
        return;
      }
      
      // Usar AssignmentUtils para crear una asignación
      final success = await AssignmentUtils.createAssignment(
        supabase, 
        orderId, 
        driverId,
      );
      
      if (success) {
        print('Asignación creada correctamente');
      } else {
        print('Error al crear asignación');
      }
    } catch (e) {
      print('Error en ejemplo de creación: $e');
    }
  }
}
