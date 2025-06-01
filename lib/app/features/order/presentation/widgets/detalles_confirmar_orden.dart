import 'package:flutter/material.dart';
import 'package:nicoya_now/app/features/order/data/datasources/order_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DetallesConfirmarOrden extends StatelessWidget {
  const DetallesConfirmarOrden({
    super.key,
    required this.total,
    required double costoEnvio,
    required double iva,
    required double precioTotal,
  }) : _costoEnvio = costoEnvio,
       _iva = iva,
       _precioTotal = precioTotal;

  final double? total;
  final double _costoEnvio;
  final double _iva;
  final double _precioTotal;

  @override
  Widget build(BuildContext context) {
    return Container(
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

                  // ignore: use_build_context_synchronously
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
    );
  }
}
