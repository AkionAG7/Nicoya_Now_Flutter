import 'package:flutter/material.dart';
import 'package:nicoya_now/app/features/order/data/datasources/order_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum PaymentMethod { Efectivo, Sinpe }

class Pago extends StatefulWidget {
  const Pago({Key? key}) : super(key: key);

  @override
  _PagoState createState() => _PagoState();
}

class _PagoState extends State<Pago> {
  PaymentMethod _metodoSeleccionado = PaymentMethod.Efectivo;
  final double _costoEnvio = 1500.0;
  late double _iva;
  late double _precioTotal;

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
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xFFfee5e9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Método de pago',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Opción Efectivo
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        leading: Image.asset(
                          'lib/app/interface/Public/Efectivo.png',
                          width: 36,
                          height: 36,
                        ),
                        title: const Text(
                          'Efectivo',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        trailing: Radio<PaymentMethod>(
                          value: PaymentMethod.Efectivo,
                          groupValue: _metodoSeleccionado,
                          activeColor: Colors.black,
                          onChanged: (value) {
                            setState(() {
                              _metodoSeleccionado = value!;
                            });
                          },
                        ),
                        onTap: () {
                          setState(() {
                            _metodoSeleccionado = PaymentMethod.Efectivo;
                          });
                        },
                      ),
                    ),
                    // Opción Sinpe Movil
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        leading: Image.asset(
                          'lib/app/interface/Public/Sinpe.png',
                          width: 36,
                          height: 36,
                        ),
                        title: const Text(
                          'Sinpe Movil',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        trailing: Radio<PaymentMethod>(
                          value: PaymentMethod.Sinpe,
                          groupValue: _metodoSeleccionado,
                          activeColor: Colors.blue, // Check azul
                          onChanged: (value) {
                            setState(() {
                              _metodoSeleccionado = value!;
                            });
                          },
                        ),
                        onTap: () {
                          setState(() {
                            _metodoSeleccionado = PaymentMethod.Sinpe;
                          });
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xFFf10027),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sub total:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            '$total CRC',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Cargo de envio:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            '$_costoEnvio CRC',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'IVA:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            '$_iva CRC',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            '$_precioTotal CRC',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () async {
                            final supa = Supabase.instance.client;
                            final userId = supa.auth.currentUser?.id;

                            if (userId != null) {
                              final datasource = OrderDatasourceImpl(
                                supabaseClient: supa,
                              );
                              await datasource.confirmOrder(
                                userId,
                              ); // Cambia el estado en la DB
                            }
                            Navigator.pushNamed(context, '/orderSuccess');
                          },
                          child: Text(
                            'Realizar mi pedido',
                            style: TextStyle(
                              color: Color(0xFFf10027),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
