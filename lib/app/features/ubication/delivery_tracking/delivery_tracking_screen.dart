import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nicoya_now/app/features/ubication/delivery_tracking/Tracking_map.dart';

class DeliveryTrackingScreen extends StatelessWidget {
  final Map<String, dynamic>? orderData;
  
  const DeliveryTrackingScreen({super.key, this.orderData});

  @override
  Widget build(BuildContext context) {
    // Extraer la ubicación del comercio de los datos de la orden
    LatLng? merchantLocation;
    if (orderData != null && 
        orderData!['merchant'] != null &&
        orderData!['merchant']['lat'] != null &&
        orderData!['merchant']['lng'] != null) {
      merchantLocation = LatLng(
        double.parse(orderData!['merchant']['lat'].toString()),
        double.parse(orderData!['merchant']['lng'].toString()),
      );
    }
    
    // Extraer el nombre del comercio
    String merchantName = orderData?['merchant']?['business_name'] ?? 'Comercio';
    
    // En una app real, la ubicación del repartidor vendría de un servicio de ubicación
    // Aquí podemos usar la ubicación del conductor si está disponible en orderData
    LatLng? driverLocation;
    // Si hay datos de geolocalización del repartidor en la orden
    if (orderData != null && 
        orderData!['driver_location'] != null &&
        orderData!['driver_location']['lat'] != null &&
        orderData!['driver_location']['lng'] != null) {
      driverLocation = LatLng(
        double.parse(orderData!['driver_location']['lat'].toString()),
        double.parse(orderData!['driver_location']['lng'].toString()),
      );
    }
      return Scaffold(
      appBar: AppBar(
        title: Text('Seguimiento de entrega'),
        backgroundColor: const Color(0xFFE60023),
        foregroundColor: Colors.white,
        actions: [
          // Botón de ayuda para mostrar instrucciones
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Cómo usar el mapa'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: Icon(Icons.touch_app, color: Colors.blue),
                        title: Text('Desplazar'),
                        subtitle: Text('Desliza con un dedo para moverte por el mapa'),
                      ),
                      ListTile(
                        leading: Icon(Icons.zoom_in, color: Colors.blue),
                        title: Text('Zoom'),
                        subtitle: Text('Pellizca con dos dedos para acercar o alejar'),
                      ),
                      ListTile(
                        leading: Icon(Icons.gps_fixed, color: Colors.blue),
                        title: Text('Seguimiento'),
                        subtitle: Text('Usa el botón azul para activar/desactivar el seguimiento automático'),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Entendido'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Mapa en pantalla completa para mejor experiencia
          TrackingMap(
            initialDriverLocation: driverLocation,
            merchantLocation: merchantLocation,
            merchantName: merchantName,
            driverName: 'Tu repartidor',
          ),
            // Panel de información simplificado (sin DraggableScrollableSheet)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: false, // Permitir interacciones con el panel pero no interferir con el mapa
              child: Container(
                constraints: BoxConstraints(maxHeight: 160), // Altura fija más pequeña
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                  children: [
                    // Indicador de arrastre
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    
                    // Tiempo estimado
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.access_time, color: Color(0xFFE60023)),
                        SizedBox(width: 8),
                        Text(
                          'Llegada estimada: 15-25 min',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    
                    Divider(height: 24),
                    
                    // Dirección de entrega
                    Text(
                      'Entrega a:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Color(0xFFE60023), size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            orderData?['delivery_address']?['street'] ?? 'Dirección no disponible',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 16),
                      // Instrucciones para usar el mapa
                    Text(
                      '¿Dificultad para navegar el mapa?',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 16),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Usa dos dedos para hacer zoom y un dedo para desplazarte por el mapa',
                            style: TextStyle(fontSize: 14, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                    ],
                  ),
                ),
              ),
            ),
          ),],
      ),
    );
  }
}
