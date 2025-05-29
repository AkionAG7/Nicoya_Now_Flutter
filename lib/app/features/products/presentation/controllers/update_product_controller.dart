import 'package:nicoya_now/app/features/products/domain/entities/products.dart';
import 'package:nicoya_now/app/features/products/domain/usecases/update_product_usecase.dart';

class EditProductController {
  final UpdateProductUseCase updateProductUseCase;

  EditProductController({required this.updateProductUseCase});

  Future<void> update(Product product) {
    return updateProductUseCase(product);
  }
}
