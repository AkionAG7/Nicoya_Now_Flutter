// lib/app/features/order/domain/usecases/change_order_status_usecase.dart

import '../entities/order.dart';
import '../repositories/order_repository.dart';

class ChangeOrderStatusUseCase {
  final OrderRepository _repository;
  ChangeOrderStatusUseCase(this._repository);

  /// Cambia el estado de la orden. Devuelve Future void o lanza excepción en caso de fallo.
  Future<void> call(String orderId, OrderStatus newStatus) async {
    return _repository.changeOrderStatus(orderId, newStatus);
  }
}
