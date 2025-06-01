import 'package:flutter/material.dart';
import '../../domain/entities/products.dart';
import '../../domain/usecases/add_product_usecase.dart';

class AddProductsController extends ChangeNotifier {
  final AddProductUseCase addProductUseCase;

  AddProductsController({required this.addProductUseCase});

  Future<void> addProduct(Product product) async {
    try {
      await addProductUseCase.execute(product);
      // mostrar success
    } catch (e) {
      // ignore: avoid_print
      print('Error al agregar producto: $e');
      // mostrar error
    }
  }
}
