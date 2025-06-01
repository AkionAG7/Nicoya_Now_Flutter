import 'package:flutter/material.dart';
import 'package:nicoya_now/app/features/products/domain/entities/products.dart';

class ProductDetailImage extends StatelessWidget {
  const ProductDetailImage({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height / 2,
          width: double.infinity,
          child: Image.network(product.image_url!, fit: BoxFit.cover),
        ),

        // El appbar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white, size: 40),
          ),
        ),

        Positioned(
          left: 0,
          right: 0,
          top: MediaQuery.of(context).size.height * 0.45,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
          ),
        ),
      ],
    );
  }
}
