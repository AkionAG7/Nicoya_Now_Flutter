import 'package:flutter/material.dart';
import 'package:nicoya_now/app/features/products/domain/entities/products.dart';
import 'package:nicoya_now/app/features/merchant/domain/usecases/fetch_merchant_products_usecase.dart';

enum MerchantProductsState { initial, loading, loaded, error }

class MerchantProductsController extends ChangeNotifier {
  final FetchMerchantProductsUseCase _fetchUseCase;

  MerchantProductsController({ required FetchMerchantProductsUseCase fetchUseCase })
    : _fetchUseCase = fetchUseCase;

  MerchantProductsState _state = MerchantProductsState.initial;
  List<Product> _products = [];
  String? _error;

  MerchantProductsState get state => _state;
  List<Product>        get products => _products;
  String?              get error   => _error;

  Future<void> fetchProducts(String merchantId) async {
    _state = MerchantProductsState.loading;
    notifyListeners();

    try {
      _products = await _fetchUseCase.call(merchantId);
      _state    = MerchantProductsState.loaded;
    } catch (e) {
      _error = e.toString();
      _state = MerchantProductsState.error;
    }

    notifyListeners();
  }
}
