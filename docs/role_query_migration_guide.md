# Guía para Migrar Consultas de Roles en Nicoya Now Flutter

## Problema

Las consultas a la tabla `role` que utilizan el campo `role` para filtrar (como `eq('role', 'driver')`) están causando errores porque la estructura de la base de datos ha cambiado y ahora se utiliza el campo `slug` en su lugar.

## Solución

### 1. Reemplazar consultas directas

**Antes:**
```dart
final row = await supabase.from('role').select().eq('role', 'driver').single();
```

**Después:**
```dart
final row = await supabase.from('role').select().eq('slug', 'driver').single();
```

### 2. Utilizar las utilidades proporcionadas en `RoleUtils`

Hemos añadido nuevas funciones en la clase `RoleUtils` que manejan de forma segura las consultas a la tabla de roles:

```dart
import 'package:nicoya_now/app/core/utils/role_utils.dart';

// Obtener un rol por su slug
final driverRole = await RoleUtils.getRoleBySlug(supabase, 'driver');

// Obtener el ID de un rol por su slug
final driverRoleId = await RoleUtils.getRoleIdBySlug(supabase, 'driver');

// Verificar si un usuario tiene un rol específico
final isDriver = await RoleUtils.hasRole(supabase, userId, 'driver');

// Obtener todos los roles de un usuario
final userRoles = await RoleUtils.getRolesForUser(supabase, userId);

// Buscar roles con criterios específicos
final roles = await RoleUtils.findRoles(supabase, roleType: 'driver');
```

### 3. Verificación y pruebas

Después de actualizar todas las consultas:

1. Busca en todo el código referencias a `eq('role'` y asegúrate de que todas han sido modificadas.
2. Prueba todas las funcionalidades relacionadas con roles para asegurar que funcionan correctamente.

## Notas importantes

- La tabla `role` tiene una columna `slug` que reemplaza la funcionalidad de la antigua columna `role`.
- Los valores comunes de `slug` son: `'customer'`, `'driver'`, `'merchant'`, `'admin'`.
- Las consultas directas a la columna `role` producirán errores como `column role does not exist`.
- Utiliza siempre las utilidades proporcionadas cuando sea posible para evitar futuros problemas.

## Ejemplo de migración completa

**Archivo antiguo:**
```dart
Future<bool> isUserDriver(String userId) async {
  try {
    final roleResult = await supabase
        .from('role')
        .select('role_id')
        .eq('role', 'driver')
        .single();
    
    final roleId = roleResult['role_id'];
    
    final userRoleResult = await supabase
        .from('user_role')
        .select()
        .eq('user_id', userId)
        .eq('role_id', roleId)
        .maybeSingle();
    
    return userRoleResult != null;
  } catch (e) {
    print('Error checking role: $e');
    return false;
  }
}
```

**Archivo migrado:**
```dart
Future<bool> isUserDriver(String userId) async {
  // Utilizamos directamente la función de RoleUtils
  return await RoleUtils.hasRole(supabase, userId, 'driver');
}
```

## Soporte y ayuda

Si encuentras algún problema al realizar esta migración, consulta los ejemplos en:
`lib/app/core/examples/role_query_example.dart`
