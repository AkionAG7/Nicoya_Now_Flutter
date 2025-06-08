import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized error handling for the application
class ErrorHandler {
  /// Log and process errors
  static void handleError(dynamic error, [StackTrace? stackTrace]) {
    if (error is PostgrestException) {
      // Handle Supabase PostgrestException specifically
      debugPrint('ERROR SUPABASE [${error.code}]: ${error.message}');
      debugPrint('DETAILS: ${error.details}');
    } else {
      // Handle general errors
      debugPrint('ERROR: ${error.toString()}');
    }
    
    // Log stack trace if available
    if (stackTrace != null) {
      debugPrint('STACK TRACE:\n$stackTrace');
    }
  }
  
  /// Show user-friendly error message based on error type
  static String getUserFriendlyMessage(dynamic error) {
    if (error is PostgrestException) {
      switch (error.code) {
        case '23505': // Unique constraint violation
          return 'Ya existe un registro con esta información.';
        case '23503': // Foreign key constraint violation
          return 'La operación no se puede completar porque el registro está vinculado a otros datos.';
        case '42703': // Undefined column
          return 'Error en la base de datos: columna no encontrada.';
        case 'PGRST116': // Row level security policy violation
          return 'No tienes permiso para realizar esta acción.';
        case '42P01': // Undefined table  
          return 'Error en la base de datos: tabla no encontrada.';
        default:
          return 'Error de base de datos: ${error.message}';
      }
    }
    
    return 'Ha ocurrido un error. Por favor intenta nuevamente.';
  }
}
