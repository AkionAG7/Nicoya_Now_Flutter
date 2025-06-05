import 'package:nicoya_now/app/core/utils/uuid_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Clase de utilidad para manejar llamadas RPC a Supabase de forma segura
class RpcUtils {
  /// Ejecuta una llamada RPC de forma segura, manejando correctamente los UUIDs
  /// 
  /// [supabase]: Cliente de Supabase
  /// [functionName]: Nombre de la función RPC
  /// [params]: Parámetros de la función RPC (pueden contener UUIDs)
  static Future<Map<String, dynamic>> callRpcSafely(
    SupabaseClient supabase, 
    String functionName, 
    Map<String, dynamic> params
  ) async {
    // Procesar los parámetros para asegurar que los UUIDs están formateados correctamente
    final processedParams = _processParams(params);
    
    try {
      // Realizar la llamada RPC sin especificar schema (asumiendo public)
      final response = await supabase.rpc(functionName, params: processedParams);
      return response is Map<String, dynamic> 
          ? response 
          : {'data': response};
    } catch (e) {
      //ignore: avoid_print
      print('Error en llamada RPC a $functionName: $e');
      rethrow; // Propagar el error para que el llamador pueda manejarlo
    }
  }
  
  /// Ejecuta una llamada RPC que devuelve una lista de registros
  static Future<List<Map<String, dynamic>>> callRpcList(
    SupabaseClient supabase, 
    String functionName, 
    Map<String, dynamic> params
  ) async {
    // Procesar los parámetros para asegurar que los UUIDs están formateados correctamente
    final processedParams = _processParams(params);
    
    try {
      // Realizar la llamada RPC sin especificar schema (asumiendo public)
      final response = await supabase.rpc(functionName, params: processedParams);
      
      if (response is List) {
        return response.map((item) {
          if (item is Map<String, dynamic>) {
            return item;
          }
          return <String, dynamic>{'value': item};
        }).toList();
      }
      
      // Si no es una lista, devolvemos una lista con un solo elemento
      return [
        response is Map<String, dynamic> ? response : {'value': response}
      ];
    } catch (e) {
      //ignore: avoid_print
      print('Error en llamada RPC a $functionName: $e');
      rethrow; // Propagar el error para que el llamador pueda manejarlo
    }
  }
  
  /// Procesa recursivamente los parámetros para asegurar que los UUIDs estén formateados correctamente
  static Map<String, dynamic> _processParams(Map<String, dynamic> params) {
    final result = <String, dynamic>{};
    
    params.forEach((key, value) {
      if (value is String && UuidUtils.isValidUuid(value)) {
        // Si es un UUID, asegurarse de que esté formateado correctamente
        result[key] = UuidUtils.parseUuid(value);
      } else if (value is Map<String, dynamic>) {
        // Si es un mapa, procesarlo recursivamente
        result[key] = _processParams(value);
      } else {
        // De lo contrario, usar el valor tal cual
        result[key] = value;
      }
    });
    
    return result;
  }
    /// Ejecuta una función RPC específica para obtener una asignación por ID de orden y conductor
  static Future<Map<String, dynamic>?> getAssignmentById(
    SupabaseClient supabase, 
    String driverId,
    String orderId
  ) async {
    try {
      // Formatear correctamente los UUIDs
      final formattedDriverId = UuidUtils.parseUuid(driverId);
      final formattedOrderId = UuidUtils.parseUuid(orderId);
      
      // Llamar a la nueva función SQL que usa 'slug' en lugar de 'role'
      final result = await supabase.rpc(
        'get_assignment_by_id', 
        params: {
          'driver_id_param': formattedDriverId,
          'order_id_param': formattedOrderId,
        }
      );
      
      if (result == null) {
        return null;
      }
      
      if (result is List && result.isNotEmpty) {
        return result.first as Map<String, dynamic>;
      }
      
      return result is Map<String, dynamic> ? result : {'data': result};
    } catch (e) {
      //ignore: avoid_print
      print('Error obteniendo asignación por ID: $e');
      return null;
    }
  }
  
  /// Verifica si un pedido debe mostrarse como "in_process" basado en su estado y asignaciones
  /// 
  /// [order]: Los datos del pedido a verificar
  /// [driverId]: El ID del conductor actual
  /// 
  /// Retorna true si el pedido debe tratarse como "in_process", false en caso contrario
  static bool shouldShowAsInProcess(Map<String, dynamic> order, String driverId) {
    // Si ya está en in_process, retornar true
    if (order['status'] == 'in_process') {
      return true;
    }
    
    // Si está pendiente y tiene una asignación para este conductor, retornar true
    if (order['status'] == 'pending') {
      // Verificar si hay una asignación directamente en el objeto
      if (order['assigned_at'] != null && 
          order['driver_id']?.toString() == driverId) {
        return true;
      }
    }
    
    // En cualquier otro caso, retornar false
    return false;
  }
}
