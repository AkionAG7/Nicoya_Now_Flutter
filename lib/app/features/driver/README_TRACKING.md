# Nicoya Now - Driver Delivery Tracking

Este proyecto implementa un sistema de seguimiento de entregas para repartidores de Nicoya Now, integrando mapas, estados de pedidos en tiempo real y actualización de ubicación.

## Funcionalidades Implementadas

1. **Visualización de Pedidos Activos:**
   - Los pedidos se muestran en tiempo real
   - Información completa del comercio y cliente
   - Estados de pedido: Asignado, Recogido, En camino, Entregado

2. **Seguimiento en Mapa:**
   - Visualización del mapa con marcadores de ubicación
   - Ubicación del repartidor en tiempo real
   - Ubicaciones del comercio y cliente

3. **Panel de Progreso:**
   - Visualización del estado actual del pedido
   - Barra de progreso con iconos
   - Estimación de tiempo de entrega

4. **Acciones de Entrega:**
   - Botones para actualizar estado del pedido
   - Navegación al lugar de recogida y entrega

## Archivos Implementados

- `active_order_tracking.dart`: Widget principal para seguimiento de entregas
- `driver_controller_enhanced.dart`: Controlador mejorado con soporte para seguimiento
- `active_order_tracking_test.dart`: Archivo de prueba para demostraciones
- `home_driver_page_updated.dart`: Página principal actualizada con integración de seguimiento

## Uso

### Integración del Seguimiento en la Página Principal

1. Importar los archivos necesarios:
   ```dart
   import 'package:nicoya_now/app/features/driver/presentation/widgets/active_order_tracking.dart';
   ```

2. Verificar pedidos activos en el método `_buildHomeTab`:
   ```dart
   Widget _buildHomeTab(DriverController controller) {
     // Check if there are active orders for delivery tracking
     final bool hasActiveOrder = controller.activeOrders.isNotEmpty;
     
     // If there's an active order, show the tracking screen
     if (hasActiveOrder) {
       Map<String, dynamic> activeOrder = controller.activeOrders.first;
       return ActiveOrderTrackingWidget(controller: controller, activeOrder: activeOrder);
     }

     // Otherwise show the regular home tab
     return SingleChildScrollView(
       // ...resto del código
     );
   }
   ```

3. Agregar navegación a la pantalla de seguimiento desde las tarjetas de pedidos:
   ```dart
   ElevatedButton.icon(
     icon: Icon(Icons.navigation),
     label: Text('Navegar'),
     style: ElevatedButton.styleFrom(
       backgroundColor: Colors.blue,
       foregroundColor: Colors.white,
     ),
     onPressed: () {
       // Navigate using the tracking widget
       final activeOrder = order;
       Navigator.push(
         context,
         MaterialPageRoute(
           builder: (context) => ActiveOrderTrackingWidget(
             controller: Provider.of<DriverController>(context, listen: false),
             activeOrder: activeOrder,
           ),
         ),
       );
     },
   ),
   ```

## Prueba del Componente

Para probar el funcionamiento, ejecuta:

```bash
flutter run -t lib/active_order_tracking_test.dart
```

## Estructura de Datos

### Pedido (Order)
```json
{
  "order_id": "uuid",
  "status": "assigned|picked_up|on_the_way|delivered",
  "customer": {
    "name": "string",
    "phone": "string"
  },
  "merchant": {
    "business_name": "string",
    "address": "string",
    "latitude": double,
    "longitude": double,
  },
  "delivery_address": "string",
  "delivery_latitude": double,
  "delivery_longitude": double
}
```

### Asignación de Pedido (Order Assignment)
```json
{
  "order_id": "uuid",
  "driver_id": "uuid",
  "assigned_at": "timestamp",
  "picked_up_at": "timestamp",
  "delivered_at": "timestamp"
}
```

## Recomendaciones para Producción

1. Implementar actualizaciones de ubicación en tiempo real con eventos de Supabase
2. Agregar estimaciones de tiempo basadas en la distancia real
3. Implementar notificaciones push para alertar sobre cambios de estado
4. Integrar servicios de rutas para optimización del recorrido
