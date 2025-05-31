// lib/app/features/order/presentation/controllers/change_order_status_controller.dart

import 'package:flutter/foundation.dart';
import 'package:nicoya_now/app/features/order/domain/usecases/change_order_status_usecase.dart';
import 'package:nicoya_now/app/features/order/domain/entities/order.dart';

class ChangeOrderStatusController extends ChangeNotifier {
  final ChangeOrderStatusUseCase _changeStatusUseCase;

  ChangeOrderStatusController({ required ChangeOrderStatusUseCase changeStatusUseCase })
      : _changeStatusUseCase = changeStatusUseCase;

  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;

  /// Acepta el pedido cambiando su estado a `accepted`
  Future<void> acceptOrder(String orderId) async {
    _setLoading(true);
    try {
      await _changeStatusUseCase(orderId, OrderStatus.accepted);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  /// Cancela el pedido cambiando su estado a `cancelled`
  Future<void> cancelOrder(String orderId) async {
    _setLoading(true);
    try {
      await _changeStatusUseCase(orderId, OrderStatus.cancelled);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }
}
