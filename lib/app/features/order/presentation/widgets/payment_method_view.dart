import 'package:flutter/material.dart';
import 'package:nicoya_now/app/core/enums/payment_method.dart';

class PaymentMethodView extends StatelessWidget {
  final PaymentMethod metodoSeleccionado;
  final ValueChanged<PaymentMethod> onChanged;
  const PaymentMethodView({
    super.key,
    required this.metodoSeleccionado,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    
    return Container(
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          // Opción Efectivo
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                value: PaymentMethod.efectivo,
                groupValue: metodoSeleccionado,
                activeColor: Colors.black,
                onChanged: (value) {
                  if (value != null) onChanged(value);
                },
              ),
              onTap: () {
                onChanged(PaymentMethod.efectivo);
              },
            ),
          ),
          // Opción Sinpe Movil
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                value: PaymentMethod.sinpe,
                groupValue: metodoSeleccionado,
                activeColor: Colors.blue, // Check azul
                onChanged: (value) {
                  if (value != null) onChanged(value);
                },
              ),
              onTap: () {
                onChanged(PaymentMethod.sinpe);
              },
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
