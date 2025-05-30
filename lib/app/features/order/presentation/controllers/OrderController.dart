import 'package:flutter/material.dart';
import 'package:nicoya_now/app/features/order/domain/entities/order.dart';
import 'package:nicoya_now/app/features/order/domain/repositories/order_repository.dart';

/// Controller para gestionar la carga de pedidos por merchant
class OrderController extends ChangeNotifier {
  final OrderRepository _repository;

  List<Order> _orders = [];
  bool _loading = false;
  String? _error;

  OrderController({required OrderRepository repository}) : _repository = repository;

  Order? _selectedOrder;
  Order? get selectedOrder => _selectedOrder;

  Future<void> loadOrderById(String orderId) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _selectedOrder = await _repository.getOrderById(orderId);
    } catch (e) {
      _error = e.toString();
      _selectedOrder = null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Lista de pedidos cargados
  List<Order> get orders => _orders;

  /// Estado de carga
  bool get loading => _loading;

  /// Error en la carga, si existe
  String? get error => _error;

  /// Carga los pedidos para el merchant dado
  Future<void> loadOrders(String merchantId) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _repository.getOrdersByMerchantId(merchantId);
      _orders = result;
    } catch (e) {
      _error = e.toString();
      _orders = [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
