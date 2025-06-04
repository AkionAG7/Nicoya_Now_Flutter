import 'package:flutter/material.dart';
import 'package:nicoya_now/app/features/ubication/delivery_tracking/top_status_panel.dart';
import 'package:nicoya_now/app/features/ubication/delivery_tracking/tracking_map.dart';
import 'package:nicoya_now/app/features/ubication/delivery_tracking/bottom_delivery_infro.dart';
import 'package:nicoya_now/app/features/ubication/delivery_tracking/delivery_status.dart';
import 'package:nicoya_now/app/features/ubication/delivery_tracking/ubication_controller.dart';
import 'package:provider/provider.dart';

class DeliveryTrackingScreen extends StatefulWidget {
  const DeliveryTrackingScreen({super.key});

  @override
  State<DeliveryTrackingScreen> createState() => _DeliveryTrackingScreenState();
}

class _DeliveryTrackingScreenState extends State<DeliveryTrackingScreen> {
  final ubicacionController = UbicacionController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _mostrarDialogoPermiso();
    });
  }

  void _mostrarDialogoPermiso() async {
    final permiso = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Permiso de Ubicación"),
          content: const Text(
            "¿Quieres permitir que esta app acceda a tu ubicación para brindarte un mejor servicio?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Permitir"),
            ),
          ],
        );
      },
    );

    if (permiso == true) {
      final ubicacion = await ubicacionController.obtenerUbicacion();
      if (ubicacion != null) {
        //ignore: avoid_print
        print("Ubicación obtenida: ${ubicacion.latitude}, ${ubicacion.longitude}");
      } else {
        //ignore: avoid_print
        print("No se pudo obtener la ubicación");
      }
    }
  }

 @override
Widget build(BuildContext context) {
  return ChangeNotifierProvider(
    create: (_) => DeliveryState(),
    child: Scaffold(
      body: Stack(
        children: [
          const TrackingMap(),

          // TopStatusPanel
          const Positioned(
            top: 65,
            left: 20,
            right: 20,
            child: TopStatusPanel(),
          ),

          // BottomDeliveryInfo
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomDeliveryInfo(),
          ),

          //  Botón exit 
          Positioned(
            top: 20,
            left: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context); 
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.deepOrange, size: 20),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
