import 'package:uuid/uuid.dart';

/// Utilidad para manejar UUIDs de forma segura en llamadas a Supabase
class UuidUtils {
  static const Uuid _uuid = Uuid();
  
  /// Convierte un string en un UUID válido para usar en consultas Supabase
  /// Esto es útil para versiones antiguas de supabase_flutter que requieren
  /// un formato específico de UUID
  static String parseUuid(String uuidStr) {
    if (uuidStr.isEmpty) {
      return '';
    }
    
    try {
      // Verificar si tiene el formato UUID básico (8-4-4-4-12)
      final pattern = RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
          caseSensitive: false);
      
      if (pattern.hasMatch(uuidStr)) {
        return uuidStr;
      } else {
        // Si no tiene el formato correcto, intentamos regenerar un formato 
        // compatible eliminando guiones, etc.
        final cleaned = uuidStr.replaceAll(RegExp(r'[^0-9a-f]'), '');
        if (cleaned.length == 32) {
          // Si tiene 32 caracteres hexadecimales, formateamos como UUID
          return '${cleaned.substring(0, 8)}-${cleaned.substring(8, 12)}-'
              '${cleaned.substring(12, 16)}-${cleaned.substring(16, 20)}-${cleaned.substring(20)}';
        }
      }
      
      // Si todo falla, devolvemos el original
      return uuidStr;
    } catch (e) {
      //ignore: avoid_print
      print('Error parseando UUID: $e');
      return uuidStr; // Devolver el original en caso de error
    }
  }
  
  /// Genera un nuevo UUID v4 como String
  static String generateUuid() {
    return _uuid.v4();
  }
  
  /// Valida si un string es un UUID válido usando una expresión regular simple
  static bool isValidUuid(String str) {
    if (str.isEmpty) {
      return false;
    }
    
    try {
      final pattern = RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
          caseSensitive: false);
      return pattern.hasMatch(str);
    } catch (e) {
      return false;
    }
  }
}
