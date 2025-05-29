import 'package:flutter/material.dart';

class BottomDeliveryInfo extends StatefulWidget {
  final String repartidorNombre;
  final String repartidorImagen;
  final String direccionComercio;

  /// dinámico: recibe nombre, imagen y dirección estilo CR (tomar en cuenta que no se como se llama XD)
  /// Ejemplo:
  /// BottomDeliveryInfo(
  ///   repartidorNombre: repartidor.nombre,
  ///   repartidorImagen: repartidor.imagen,
  ///   direccion: comercio.direccion,
  /// )

  const BottomDeliveryInfo({
    super.key,
    this.repartidorNombre = "Akion Cheng",
    this.repartidorImagen = "lib/app/interface/public/Repartidor.png",
    this.direccionComercio =
        "25 metros norte del Liceo de Nicoya, frente a piscinas ANDE",
  });

  @override
  State<BottomDeliveryInfo> createState() => _BottomDeliveryInfoState();
}

class _BottomDeliveryInfoState extends State<BottomDeliveryInfo> {
  int estadoIndex = 0;

  final List<String> estados = [
    "Pedido aceptado",
    "Preparando",
    "En camino",
    "Entregado",
  ];

  @override
  void initState() {
    super.initState();
    _cambiarEstado();
  }

  void _cambiarEstado() {
    Future.delayed(const Duration(seconds: 10), () {
      if (estadoIndex < estados.length - 1) {
        setState(() {
          estadoIndex++;
        });
        _cambiarEstado(); // Se repete hasta que llega al último estado
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fondo rojo con repartidor
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFf10027),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage: AssetImage(widget.repartidorImagen),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.repartidorNombre,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const Text(
                      "Repartidor",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Caja blanca con detalles
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dirección del comercio
                Row(
                  children: const [
                    Icon(Icons.location_on_outlined,
                        size: 16, color: Colors.grey),
                    SizedBox(width: 6),
                    Text(
                      "Dirección del comercio",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.direccionComercio,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Divider(height: 20),

               
                Row(
                  children: const [
                    Icon(Icons.access_time, size: 16, color: Colors.grey),
                    SizedBox(width: 6),
                    Text(
                      "Estado",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  estados[estadoIndex],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
