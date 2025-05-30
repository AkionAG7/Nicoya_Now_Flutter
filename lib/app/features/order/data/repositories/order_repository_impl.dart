import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_datasource.dart';

/// Implementación concreta del repositorio, que delega en el DataSource.
class OrderRepositoryImpl implements OrderRepository {
  final OrderDatasource _datasource;

  OrderRepositoryImpl({ required OrderDatasource datasource })
    : _datasource = datasource;

      @override
  Future<Order> getOrderById(String orderId) {
    return _datasource.getOrderById(orderId);
  }


  @override
  Future<List<Order>> getOrdersByMerchantId(String merchantId) async {
    try {
      return await _datasource.getOrdersByMerchantId(merchantId);
    } catch (e) {
      // Aquí podrías mapear excepciones a tus propios errores de dominio
      rethrow;
    }
  }
}
