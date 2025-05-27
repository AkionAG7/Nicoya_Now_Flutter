# Flujo de Gestión de Múltiples Roles

## Descripción General
Este documento describe la implementación del sistema de múltiples roles que permite a los usuarios existentes agregar nuevos roles (conductor, comerciante, cliente) a sus cuentas sin necesidad de crear nuevas cuentas.

## Arquitectura Implementada

### 1. Componentes Principales

#### AuthController
- `handleRoleAdditionFlow()`: Verifica credenciales y valida si el usuario ya tiene el rol
- `addRoleToCurrentUser()`: Agrega un nuevo rol al usuario actual
- `handleLoginWithRoleSelection()`: Maneja login con selección de rol múltiple

#### Páginas Nuevas
- **SelectUserRolePage**: Selección de rol cuando usuario tiene múltiples roles
- **AddRolePage**: Verificación de identidad para agregar nuevo rol
- **RoleFormPage**: Formulario genérico para recopilar datos específicos del rol

#### Servicios
- **RoleService**: Gestión completa de roles (obtener, agregar, verificar)
- **Use Cases**: `GetUserRolesUseCase`, `AddUserRoleUseCase`

### 2. Flujos de Navegación

#### A. Usuario Nuevo Registrándose
```
Home → "Registrarse" → SelectTypeAccount → [Tipo de Cuenta] → Formulario Completo → Registro
```

#### B. Usuario Existente Agregando Rol
```
Home → "Registrarse" → SelectTypeAccount → "Ya tengo cuenta" → AddRolePage → 
Verificación → RoleFormPage → Formulario Específico → Éxito
```

#### C. Login con Múltiples Roles
```
Login → Verificación → SelectUserRolePage → Selección → Pantalla Principal del Rol
```

## Implementación Específica para Conductores

### DeliverForm1.dart - Formulario Condicional

#### Campos para Usuario Existente (Agregando Rol)
- ✅ Cédula (obligatorio)
- ✅ Número de licencia (obligatorio)
- ❌ Datos personales (ya existen)
- ❌ Email/contraseña (ya autenticado)

#### Campos para Usuario Nuevo
- ✅ Cédula
- ✅ Número de licencia  
- ✅ Nombre completo
- ✅ Teléfono
- ✅ Email
- ✅ Contraseña

### Lógica Condicional

```dart
// Detectar contexto
@override
void didChangeDependencies() {
  final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
  if (args != null) {
    _isAddingRole = args['isAddingRole'] as bool? ?? false;
  }
}

// Formulario condicional
if (!_isAddingRole) {
  // Mostrar campos completos para usuario nuevo
} else {
  // Solo mostrar campos específicos para agregar rol
}

// Proceso condicional
if (_isAddingRole) {
  // Agregar rol a usuario existente
  await authController.addRoleToCurrentUser(RoleType.driver, data);
} else {
  // Registro completo de nuevo usuario
  await authController.signUpDriver(...);
}
```

## Configuración de Base de Datos

### Tabla user_roles
- `user_id`: UUID del usuario
- `role`: ENUM('customer', 'driver', 'merchant')  
- `created_at`: Timestamp
- `is_active`: Boolean

### Tabla driver (para datos específicos)
- `driver_id`: UUID (FK a auth.users)
- `license_number`: VARCHAR
- `vehicle_type`: VARCHAR
- `is_verified`: Boolean

## Beneficios de la Implementación

1. **UX Mejorada**: Los usuarios no necesitan múltiples cuentas
2. **Datos Consistentes**: Un solo perfil con múltiples roles
3. **Flexibilidad**: Fácil agregar nuevos roles
4. **Mantenimiento**: Arquitectura limpia y escalable
5. **Seguridad**: Verificación de identidad antes de agregar roles

## Casos de Uso Soportados

- ✅ Cliente que quiere ser conductor
- ✅ Conductor que quiere ser comerciante  
- ✅ Comerciante que quiere ser cliente
- ✅ Login con selección de rol activo
- ✅ Gestión de permisos por rol
- ✅ Verificación de datos específicos por rol

## Testing del Flujo

### Flujo Completo para Agregar Rol de Conductor
1. Abrir app → Pantalla Home
2. Tocar "Registrarse" → SelectTypeAccount
3. Tocar "Ya tengo cuenta" → AddRolePage
4. Ingresar email/contraseña + seleccionar "Conductor"
5. Tocar "CONTINUAR" → RoleFormPage → redirect a DeliverForm1
6. Ver formulario simplificado (solo cédula + licencia)
7. Completar y enviar → Rol agregado exitosamente

### Verificaciones
- [ ] Formulario muestra solo campos necesarios
- [ ] Título cambia a "Agregar rol de repartidor"  
- [ ] Botón dice "Agregar rol"
- [ ] No se solicita contraseña
- [ ] Datos se guardan correctamente
- [ ] Usuario puede acceder con nuevo rol
