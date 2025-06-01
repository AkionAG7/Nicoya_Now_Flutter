import 'package:flutter/material.dart';
import 'package:nicoya_now/app/features/order/data/datasources/order_item_datasource.dart';
import 'package:nicoya_now/app/features/order/domain/usecases/add_product_to_car_usecase.dart';
import 'package:nicoya_now/app/features/products/domain/entities/products.dart';
import 'package:nicoya_now/app/features/products/presentation/widgets/add_to_car_product.dart';
import 'package:nicoya_now/app/features/products/presentation/widgets/product_detail_image.dart';
import 'package:nicoya_now/app/features/products/presentation/widgets/product_detail_info.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductDetail extends StatefulWidget {
  const ProductDetail({super.key});

  @override
  ProductDetailState createState() => ProductDetailState();
}

class ProductDetailState extends State<ProductDetail> {
  int cantidad = 1;
  late final AddProductToCart addProductToCart;

  void incrementarCantidad() {
    setState(() {
      cantidad++;
    });
  }

  void decrementarCantidad() {
    setState(() {
      if (cantidad > 1) {
        cantidad--;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    final supa = Supabase.instance.client;
    final orderItemDatasource = OrderItemDatasourceImpl(supa: supa);
    addProductToCart = AddProductToCart(datasource: orderItemDatasource);
  }

  @override
  Widget build(BuildContext context) {
    final product = ModalRoute.of(context)!.settings.arguments as Product;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductDetailImage(product: product),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ProductDetailInfo(
                    product: product,
                    cantidad: cantidad,
                    onIcrement: incrementarCantidad,
                    onDecrement: decrementarCantidad,
                  ),

                  AddToCarProduct(
                    addProductToCart: addProductToCart,
                    product: product,
                    cantidad: cantidad,
                  ),

                  SizedBox(height: 0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
