import 'package:flutter/material.dart';
import 'package:nicoya_now/app/features/auth/domain/entities/products.dart';

class ProductDetail extends StatefulWidget {
  
  const ProductDetail({Key? key}) : super(key: key);

  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
    @override
  Widget build(BuildContext context) {
    final product = ModalRoute.of(context)!.settings.arguments as Product;

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.image_url != null)
              Image.network(product.image_url!, height: 250, fit: BoxFit.cover)
            else
              const Placeholder(fallbackHeight: 250),
            const SizedBox(height: 20),
            Text(product.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(product.description ?? 'Sin descripción'),
            const SizedBox(height: 10),
            Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}