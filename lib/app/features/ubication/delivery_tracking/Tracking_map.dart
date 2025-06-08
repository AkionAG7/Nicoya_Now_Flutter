import 'dart:async';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:nicoya_now/app/core/constants/map_constants.dart';

class TrackingMap extends StatefulWidget {
  final LatLng? initialDriverLocation;
  final LatLng? merchantLocation;
  final String driverName;
  final String merchantName;

  const TrackingMap({
    super.key, 
    this.initialDriverLocation,
    this.merchantLocation,
    this.driverName = "Repartidor",
    this.merchantName = "Comercio"
  });

  @override
  State<TrackingMap> createState() => _TrackingMapState();
}

class _TrackingMapState extends State<TrackingMap> {  GoogleMapController? _mapController;
  final Set<Marker> _marcadores = {};
  BitmapDescriptor? _iconoRepartidor;
  late LatLng _ubicacionRepartidor;
  late LatLng _ubicacionComercio;
  Timer? _mapUpdateTimer;
  bool _cameraFollowsDriver = true; // Para controlar si la cámara sigue al repartidor
  @override
  void initState() {
    super.initState();
    // Inicializar ubicaciones con los valores proporcionados o los predeterminados
    _ubicacionRepartidor = widget.initialDriverLocation ?? 
        const LatLng(MapConstants.defaultLatitude, MapConstants.defaultLongitude);
    
    _ubicacionComercio = widget.merchantLocation ?? 
        const LatLng(10.14353, -85.45195);
        
    _crearIconoRepartidor();
    
    // Configurar el timer que controla tanto la actualización de la posición 
    // como el seguimiento de la cámara
    _mapUpdateTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      
      // Simular movimiento del repartidor
      _simularMovimientoRepartidor();
      
      // Si está activado el seguimiento, actualizar la posición de la cámara
      if (_cameraFollowsDriver) {
        _actualizarPosicionCamara();
      }
    });
  }

  Future<void> _crearIconoRepartidor() async {
    const size = 128.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final icon = Icons.directions_bike;
    final textStyle = ui.TextStyle(
      fontSize: size,
      fontFamily: icon.fontFamily,
    );

    final paragraphBuilder =
        ui.ParagraphBuilder(ui.ParagraphStyle(textAlign: TextAlign.center))
          ..pushStyle(textStyle)
          ..addText(String.fromCharCode(icon.codePoint));

    final paragraph = paragraphBuilder.build();
    paragraph.layout(const ui.ParagraphConstraints(width: size));
    canvas.drawParagraph(paragraph, Offset.zero);

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final uint8List = byteData!.buffer.asUint8List();

    setState(() {
      _iconoRepartidor = BitmapDescriptor.fromBytes(uint8List);
      _colocarMarcadores();
    });
  }
  void _colocarMarcadores() {
    setState(() {
      _marcadores.clear();

      // Marcador del repartidor con nombre dinámico
      _marcadores.add(Marker(
        markerId: const MarkerId("repartidor"),
        position: _ubicacionRepartidor,
        icon: _iconoRepartidor ?? BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(
          title: widget.driverName,
          snippet: "En camino"
        ),
        draggable: false, // No permitir arrastrar el marcador
        zIndex: 2, // Para que aparezca encima
      ));

      // Marcador del comercio con nombre dinámico
      _marcadores.add(Marker(
        markerId: const MarkerId("comercio"),
        position: _ubicacionComercio,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: widget.merchantName,
          snippet: "Recoger aquí"
        ),
        zIndex: 1,
      ));
    });
  }
    // Reposiciones la cámara para centrar en el repartidor
  void _actualizarPosicionCamara() {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_ubicacionRepartidor, 15),
      );
    }
  }
  
  // Alternar entre seguimiento automático o movimiento libre
  void _toggleCameraFollow() {
    setState(() {
      _cameraFollowsDriver = !_cameraFollowsDriver;
      if (_cameraFollowsDriver) {
        _actualizarPosicionCamara();
      }
    });
  }
  
  // Simular actualización de posición del repartidor (en una app real, esto vendría de un GPS o servicio)
  void _simularMovimientoRepartidor() {
    // Pequeño movimiento aleatorio para simular desplazamiento
    final random = math.Random();
    final latChange = (random.nextDouble() - 0.5) * 0.001;
    final lngChange = (random.nextDouble() - 0.5) * 0.001;
    
    setState(() {
      _ubicacionRepartidor = LatLng(
        _ubicacionRepartidor.latitude + latChange,
        _ubicacionRepartidor.longitude + lngChange,
      );
      _colocarMarcadores();
    });
  }

  @override
  void dispose() {
    // Cancelar el timer al destruir el widget
    _mapUpdateTimer?.cancel();
    super.dispose();
  }  @override
  Widget build(BuildContext context) {
      // La actualización de la posición del repartidor se maneja en el timer de initState
    
    return Stack(
      children: [        // Map with gesture recognizers enabled - Versión totalmente interactiva
        AbsorbPointer(
          absorbing: false, // Fundamental: asegura que los gestos lleguen al mapa
          child: GestureDetector(
            // Esto asegura que los gestos sean capturados por el widget GestureDetector
            // pero también se pasen al mapa
            behavior: HitTestBehavior.translucent,
            onPanDown: (_) {
              // Desactivar seguimiento automático al tocar el mapa
              if (_cameraFollowsDriver) {
                setState(() => _cameraFollowsDriver = false);
              }
            },
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: _ubicacionRepartidor, zoom: 14),
              onMapCreated: (controller) {
                setState(() {
                  _mapController = controller;
                  // Al inicializar el mapa, colocamos los marcadores
                  _colocarMarcadores();
                  
                  // Configurar estilo del mapa más interactivo (si se desea)
                  // _mapController!.setMapStyle('tu_estilo_json');
                });
              },
              markers: _marcadores,
              myLocationEnabled: true, // Ubicación del usuario
              myLocationButtonEnabled: true, // Botón para centrar en ubicación del usuario
              zoomControlsEnabled: true, // Botones de zoom visibles
              
              // Aseguramos que TODOS los gestos estén activos
              zoomGesturesEnabled: true, // Habilitar gestos de zoom
              scrollGesturesEnabled: true, // FUNDAMENTAL: permite el desplazamiento
              rotateGesturesEnabled: true, // Permite rotación con gestos
              tiltGesturesEnabled: true, // Permite cambiar perspectiva
              compassEnabled: true, // Mostrar brújula
              indoorViewEnabled: true, // Permite ver mapas interiores cuando estén disponibles
              trafficEnabled: false, // Mostrar tráfico si se desea
              mapToolbarEnabled: true, // Muestra opciones de navegación al hacer clic prolongado
              
              // Manejamos explícitamente los eventos de cámara
              onCameraMove: (position) {
                // Si el usuario mueve la cámara manualmente, desactivamos el seguimiento automático
                if (_cameraFollowsDriver) {
                  setState(() => _cameraFollowsDriver = false);
                }
              },
            ),
          ),
        ),
          // Panel de controles del mapa
        Positioned(
          bottom: 110,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Control de zoom
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Zoom in
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        if (_mapController != null) {
                          _mapController!.animateCamera(CameraUpdate.zoomIn());
                        }
                      },
                    ),
                    Divider(height: 1, color: Colors.grey.shade300),
                    // Zoom out
                    IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: () {
                        if (_mapController != null) {
                          _mapController!.animateCamera(CameraUpdate.zoomOut());
                        }
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              
              // Botón para activar/desactivar seguimiento
              FloatingActionButton(
                heroTag: "btnSeguimiento",
                backgroundColor: _cameraFollowsDriver ? Colors.blue : Colors.grey,
                onPressed: _toggleCameraFollow,
                tooltip: _cameraFollowsDriver ? "Seguimiento activado" : "Seguimiento desactivado",
                child: Icon(
                  _cameraFollowsDriver ? Icons.gps_fixed : Icons.gps_not_fixed,
                  color: Colors.white,
                ),
              ),
              
              SizedBox(height: 12),
              
              // Botón para ir a la ubicación del comercio
              FloatingActionButton(
                heroTag: "btnComercio",
                backgroundColor: Colors.green,
                onPressed: () {
                  if (_mapController != null) {
                    _mapController!.animateCamera(
                      CameraUpdate.newLatLngZoom(_ubicacionComercio, 16),
                    );
                    setState(() => _cameraFollowsDriver = false);
                  }
                },
                tooltip: "Ver comercio",
                child: const Icon(Icons.store, color: Colors.white),
              ),
            ],
          ),
        ),
        
        // Indicador de modo libre
        Positioned(
          top: 16,
          left: 16,
          child: AnimatedOpacity(
            opacity: _cameraFollowsDriver ? 0.0 : 1.0,
            duration: Duration(milliseconds: 300),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.pan_tool, size: 16, color: Colors.blue),
                  SizedBox(width: 4),
                  Text("Modo libre - Desliza para navegar"),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
