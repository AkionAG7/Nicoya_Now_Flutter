import 'package:flutter/material.dart';

import 'package:nicoya_now/app/features/order/domain/usecases/calcular_total_usecase.dart';
import 'package:nicoya_now/app/features/order/domain/usecases/update_carrito_usecase.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';

class ButtomConfirmarOrden extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final UpdateCarrito updateCarrito;
  final CalcularTotal calcularTotal;
  final VoidCallback onConfirmed;

  const ButtomConfirmarOrden({
    super.key,
    required this.items,
    required this.updateCarrito,
    required this.calcularTotal,
    required this.onConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 250,
        height: 70,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFf10027),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: () async {
            await updateCarrito(items);
            final total = calcularTotal(items);
            // ignore: use_build_context_synchronously
            Navigator.pushNamed(context, Routes.pago, arguments: total);
            onConfirmed(); // llamamos para refrescar después de volver
          },
          child: const Text(
            'Confirmar orden',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
