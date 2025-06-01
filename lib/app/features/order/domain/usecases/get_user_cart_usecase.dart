import 'package:nicoya_now/app/features/order/domain/repositories/order_repository.dart';

class GetUserCart {
  final OrderRepository repo;
  GetUserCart({required this.repo});

  Future<List<Map<String, dynamic>>> call() async {
    return await repo.getCarritoActual();
  }
}