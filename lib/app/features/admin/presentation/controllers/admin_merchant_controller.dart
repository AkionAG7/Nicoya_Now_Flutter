import 'package:flutter/material.dart';

import '../../../../../app/core/error/failures.dart';
import '../../domain/entities/merchant/merchant.dart';
import '../../domain/usecases/merchant/merchant_usecases.dart';

enum AdminMerchantState { initial, loading, loaded, error }

/// Controller for managing merchants in the admin panel
class AdminMerchantController extends ChangeNotifier {
  final GetAllMerchantsUseCase _getAllMerchantsUseCase;
  final ApproveMerchantUseCase _approveMerchantUseCase;
  final RejectMerchantUseCase _rejectMerchantUseCase;

  AdminMerchantController({
    required GetAllMerchantsUseCase getAllMerchantsUseCase,
    required ApproveMerchantUseCase approveMerchantUseCase,
    required RejectMerchantUseCase rejectMerchantUseCase,
  }) : _getAllMerchantsUseCase = getAllMerchantsUseCase,
       _approveMerchantUseCase = approveMerchantUseCase,
       _rejectMerchantUseCase = rejectMerchantUseCase;

  AdminMerchantState _state = AdminMerchantState.initial;
  List<Merchant> _merchants = [];
  String? _error;

  AdminMerchantState get state => _state;
  List<Merchant> get merchants => _merchants;
  String? get error => _error;

  /// Load all merchants from the database
  Future<void> loadMerchants() async {
    //ignore: avoid_print
    print('AdminMerchantController: Starting to load merchants');
    _state = AdminMerchantState.loading;
    _error = null;
    notifyListeners();

    try {
      //ignore: avoid_print
      print('AdminMerchantController: Calling getAllMerchantsUseCase');
      final result = await _getAllMerchantsUseCase.call();
      //ignore: avoid_print
      print('AdminMerchantController: Got result from use case: $result');
      result.fold(
        (failure) {
          //ignore: avoid_print
          print(
            'AdminMerchantController: Got failure: ${failure.runtimeType} - ${failure.message}',
          );
          _error = _getFailureMessage(failure);
          _state = AdminMerchantState.error;
        },
        (merchants) {
          //ignore: avoid_print
          print(
            'AdminMerchantController: Got ${merchants.length} merchants: $merchants',
          );
          _merchants = merchants;
          _state = AdminMerchantState.loaded;
        },
      );
    } catch (e) {
      //ignore: avoid_print
      print('AdminMerchantController: Caught unexpected error: $e');
      _error = 'Error inesperado: $e';
      _state = AdminMerchantState.error;
    }
    //ignore: avoid_print
    print(
      'AdminMerchantController: Final state is $_state, error: $_error, merchants count: ${_merchants.length}',
    );
    notifyListeners();
  }

  /// Filter merchants by search query and status
  List<Merchant> getFilteredMerchants(String query, {bool? isApproved}) {
    List<Merchant> filteredList = _merchants;

    // First filter by approval status if specified
    if (isApproved != null) {
      filteredList =
          filteredList
              .where((merchant) => merchant.isVerified == isApproved)
              .toList();
    }

    // Then filter by search query if provided
    if (query.isNotEmpty) {
      filteredList =
          filteredList.where((merchant) {
            return merchant.businessName.toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                merchant.merchantId.toLowerCase().contains(query.toLowerCase());
          }).toList();
    }

    return filteredList;
  }

  /// Get pending merchants (not verified)
  List<Merchant> getPendingMerchants() {
    return _merchants.where((merchant) => !merchant.isVerified).toList();
  }

  /// Get approved merchants (verified)
  List<Merchant> getApprovedMerchants() {
    return _merchants.where((merchant) => merchant.isVerified).toList();
  }

  /// Get failure message from Failure object
  String _getFailureMessage(Failure failure) {
    if (failure is ServerFailure) {
      return 'Error del servidor. Intenta nuevamente.';
    } else if (failure is NetworkFailure) {
      return 'Error de conexión. Verifica tu internet.';
    } else {
      return 'Error desconocido. Intenta nuevamente.';
    }
  }

  /// Approve a merchant by ID
  Future<bool> approveMerchant(String merchantId) async {
    try {
      final result = await _approveMerchantUseCase.call(merchantId);
      return result.fold(
        (failure) {
          _error = _getFailureMessage(failure);
          notifyListeners();
          return false;
        },
        (approvedMerchant) {
          // Update the merchant in the local list
          final index = _merchants.indexWhere(
            (m) => m.merchantId == merchantId,
          );
          if (index != -1) {
            _merchants[index] = approvedMerchant;
            notifyListeners();
          }
          return true;
        },
      );
    } catch (e) {
      _error = 'Error inesperado: $e';
      notifyListeners();
      return false;
    }
  }

  /// Unapprove a merchant by ID (set isVerified to false)
  Future<bool> unapproveMerchant(String merchantId) async {
    try {
      final result = await _rejectMerchantUseCase.call(merchantId);
      return result.fold(
        (failure) {
          _error = _getFailureMessage(failure);
          notifyListeners();
          return false;
        },
        (unapprovedMerchant) {
          // Update the merchant in the local list
          final index = _merchants.indexWhere(
            (m) => m.merchantId == merchantId,
          );
          if (index != -1) {
            _merchants[index] = unapprovedMerchant;
            notifyListeners();
          }
          return true;
        },
      );
    } catch (e) {
      _error = 'Error inesperado: $e';
      notifyListeners();
      return false;
    }  }

  /// Refresh merchants data
  Future<void> refresh() async {
    await loadMerchants();
  }
}
