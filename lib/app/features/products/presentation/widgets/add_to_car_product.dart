import 'package:flutter/material.dart';
import 'package:nicoya_now/app/features/order/domain/exceptions/order_error_exception.dart';
import 'package:nicoya_now/app/features/order/domain/usecases/add_product_to_car_usecase.dart';
import 'package:nicoya_now/app/features/order/presentation/widgets/add_to_car_error_modal.dart';
import 'package:nicoya_now/app/features/products/domain/entities/products.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddToCarProduct extends StatelessWidget {
  const AddToCarProduct({
    super.key,
    required this.addProductToCart,
    required this.product,
    required this.cantidad,
  });

  final AddProductToCart addProductToCart;
  final Product product;
  final int cantidad;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 1.5,
        height: 50,
        child: ElevatedButton(
          onPressed: () async {
            final userId = Supabase.instance.client.auth.currentUser?.id;
            try {
              await addProductToCart(
                userId: userId!,
                product: product,
                quantity: cantidad,
              );
              // ignore: use_build_context_synchronously
              Navigator.popAndPushNamed(context, Routes.clientNav);
            } on OrderErrorException {
              //ignore: use_build_context_synchronously
              await showOrderErrorModal(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFf10027),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: const Text(
            'Agregar al carrito',
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
