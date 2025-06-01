import 'package:flutter/material.dart';
import 'package:nicoya_now/app/core/enums/payment_method.dart';
import 'package:nicoya_now/app/features/order/data/datasources/order_datasource.dart';
import 'package:nicoya_now/app/features/order/presentation/widgets/detalles_confirmar_orden.dart';
import 'package:nicoya_now/app/features/order/presentation/widgets/payment_method_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Pago extends StatefulWidget {
  const Pago({super.key});

  @override
  PagoState createState() => PagoState();
}

class PagoState extends State<Pago> {
  final double _costoEnvio = 1500.0;
  late double _iva;
  late double _precioTotal;
  PaymentMethod metodoSeleccionado = PaymentMethod.efectivo;
  @override
  Widget build(BuildContext context) {
    final total = ModalRoute.of(context)?.settings.arguments as double?;
    _iva = total! * 0.13;
    _precioTotal = total + _costoEnvio + _iva;
    return Scaffold(
      appBar: AppBar(title: const Text('Confirma tu orden')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 30,
            right: 30,
            top: 30,
            bottom: 30,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PaymentMethodView(
                metodoSeleccionado: metodoSeleccionado,
                onChanged: (nuevoMetodo) {
                  setState(() {
                    metodoSeleccionado = nuevoMetodo;
                  });
                },
              ),

              const SizedBox(height: 20),

              DetallesConfirmarOrden(
                total: total,
                costoEnvio: _costoEnvio,
                iva: _iva,
                precioTotal: _precioTotal,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
