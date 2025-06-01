import 'package:nicoya_now/app/features/products/domain/entities/products.dart';

class CalcularTotal {
  double call(List<Map<String, dynamic>> items) {
    return items.fold(0.0, (total, item) {
      final product = item['product'] as Product;
      final quantity = item['quantity'] as int;
      return total + (product.price * quantity);
    });
  }
}
