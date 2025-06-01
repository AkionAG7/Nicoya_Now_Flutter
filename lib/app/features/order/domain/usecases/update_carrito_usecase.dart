import 'package:nicoya_now/app/features/order/domain/repositories/order_repository.dart';

class UpdateCarrito {
  final OrderRepository repo;
  UpdateCarrito({required this.repo});

  Future<void> call(List<Map<String, dynamic>> items) async {
    try {
      await repo.updateOrderItems(items);
    } catch (e) {
      rethrow;
    }
  }
}
