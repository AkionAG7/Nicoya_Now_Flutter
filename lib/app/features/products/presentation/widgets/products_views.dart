import 'package:flutter/material.dart';
import 'package:nicoya_now/app/features/products/domain/entities/products.dart';
import 'package:nicoya_now/app/interface/Navigators/routes.dart';



class ProductsViews extends StatelessWidget {
  const ProductsViews({
    super.key,
    required Future<List<Product>> productsFuture,
  }) : _productsFuture = productsFuture;

  final Future<List<Product>> _productsFuture;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 400,
      child: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox.shrink();
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay productos disponibles.'));
          }

          final products = snapshot.data!;
          return GridView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 0,
              mainAxisSpacing: 0,
              childAspectRatio: 1.1,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];

              return Card(
                margin: EdgeInsets.only(
                  left: index % 2 == 0 ? 0 : 8,
                  right: 8,
                  bottom: 8,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 50,
                    height: 100,
                    child:
                        product.image_url != null
                            ? GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  Routes.product_Detail,
                                  arguments: product,
                                );
                              },
                              child: Image.network(
                                product.image_url!,
                                fit: BoxFit.cover,
                              ),
                            )
                            : const Text('No imagen suported'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
