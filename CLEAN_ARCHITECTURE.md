# Clean Architecture en Nicoya Now

## Estructura del Proyecto

La aplicación Nicoya Now ha sido organizada siguiendo los principios de Clean Architecture, lo que permite una mayor escalabilidad, mantenibilidad y testabilidad del código.

## Capas de la Aplicación

### 1. Capa de Presentación (Presentation Layer)
- **Ubicación**: `lib/app/features/{feature}/presentation/`
- **Responsabilidad**: Manejo de UI, widgets, pages y controllers relacionados con la interfaz de usuario.
- **Componentes**:
  - `pages/`: Pantallas de la aplicación
  - `controllers/`: Gestores de estado (usando Provider)
  - `widgets/`: Widgets reutilizables específicos de la feature

### 2. Capa de Dominio (Domain Layer)
- **Ubicación**: `lib/app/features/{feature}/domain/`
- **Responsabilidad**: Contiene la lógica de negocio central de la aplicación, independiente de cualquier framework o tecnología externa.
- **Componentes**:
  - `entities/`: Modelos de dominio
  - `repositories/`: Interfaces de repositorios
  - `usecases/`: Casos de uso que implementan reglas de negocio

### 3. Capa de Datos (Data Layer)
- **Ubicación**: `lib/app/features/{feature}/data/`
- **Responsabilidad**: Manejo de datos, independientemente de la fuente (API, base de datos local, etc.)
- **Componentes**:
  - `datasources/`: Fuentes de datos
  - `repositories/`: Implementaciones concretas de los repositorios definidos en el dominio

### 4. Capa Core (Core Layer)
- **Ubicación**: `lib/app/core/`
- **Responsabilidad**: Servicios y utilidades que son comunes a todas las características.
- **Componentes**:
  - `di/`: Inyección de dependencias
  - `utils/`: Utilidades generales
  - `error/`: Manejo de errores
  - `network/`: Configuración de red

## Beneficios

### Testabilidad
- Cada capa puede ser probada de forma independiente
- Facilita el uso de mock objects para tests unitarios

### Mantenibilidad
- Código más organizado y con responsabilidades claras
- Facilita el trabajo en equipo ya que cada capa tiene límites bien definidos

### Escalabilidad
- Nuevas features pueden ser añadidas sin modificar código existente
- Cambios en una capa no afectan necesariamente a otras capas

### Independencia de Frameworks
- La lógica de negocio (Domain Layer) es independiente de Flutter
- Facilita la migración a nuevas versiones o incluso diferentes frameworks

## Flujo de Datos

1. UI solicita datos a través de un Controller
2. El Controller solicita la acción a un UseCase
3. El UseCase ejecuta la lógica de negocio usando interfaces de Repository
4. El Repository implementa la lógica de acceso a datos usando DataSources
5. Los datos fluyen de vuelta a través de las capas hasta la UI

## Ejemplo de Autenticación

- **UI**: `LoginPage` solicita iniciar sesión
- **Controller**: `AuthController` coordina la solicitud
- **UseCase**: `SignInUseCase` contiene la lógica de negocio
- **Repository**: `AuthRepository` (interfaz) define el contrato
- **Implementación**: `AuthRepositoryImpl` implementa el acceso a datos
- **DataSource**: `SupabaseAuthDataSource` interactúa con Supabase

## Reglas de Dependencia

- Las capas externas pueden depender de las internas
- Las capas internas NO dependen de las externas
- Domain NO depende de Data o Presentation
- Data depende SOLO de Domain
- Presentation depende de Domain (y potencialmente de Data)
