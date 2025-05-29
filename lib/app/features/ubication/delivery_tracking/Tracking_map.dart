import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackingMap extends StatefulWidget {
  const TrackingMap({super.key});

  @override
  State<TrackingMap> createState() => _TrackingMapState();
}

class _TrackingMapState extends State<TrackingMap> {
  GoogleMapController? _mapController;
  final Set<Marker> _marcadores = {};
  BitmapDescriptor? _iconoRepartidor;

  // Inicialmente "quemados"
  LatLng _ubicacionRepartidor = const LatLng(10.15749, -85.44926);
  LatLng _ubicacionComercio = const LatLng(10.14353, -85.45195);

  @override
  void initState() {
    super.initState();
    _crearIconoRepartidor();

    //  Ejemplo de cómo se podrían recibir dinámicamente XD
    //
    // _ubicacionRepartidor = LatLng(datosRepartidor.lat, datosRepartidor.lng);
    // _ubicacionComercio = LatLng(datosComercio.lat, datosComercio.lng);
    // _colocarMarcadores();
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

      //  Repartidor
      _marcadores.add(Marker(
        markerId: const MarkerId("repartidor"),
        position: _ubicacionRepartidor,
        icon: _iconoRepartidor ?? BitmapDescriptor.defaultMarker,
        infoWindow: const InfoWindow(title: "Repartidor"),
      ));

      //  Comercio
      _marcadores.add(Marker(
        markerId: const MarkerId("comercio"),
        position: _ubicacionComercio,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: "Comercio"),
      ));

      
    });
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: _ubicacionRepartidor, zoom: 13),
      onMapCreated: (controller) => _mapController = controller,
      markers: _marcadores,
      myLocationEnabled: true, // Ubicación del usuario
      myLocationButtonEnabled: true,
      zoomControlsEnabled: false,
    );
  }
}
