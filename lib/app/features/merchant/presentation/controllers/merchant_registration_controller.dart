import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nicoya_now/app/features/merchant/domain/entities/merchant.dart';
import 'package:nicoya_now/app/features/merchant/domain/usecases/register_merchant_usecase.dart';

enum MerchantRegistrationState {
  initial,
  loading,
  success,
  error,
}

class MerchantRegistrationController extends ChangeNotifier {
  final RegisterMerchantUseCase _registerMerchantUseCase;
  
  MerchantRegistrationState _state = MerchantRegistrationState.initial;
  String? _errorMessage;
  Merchant? _merchant;

  MerchantRegistrationController({
    required RegisterMerchantUseCase registerMerchantUseCase,
  }) : _registerMerchantUseCase = registerMerchantUseCase;

  MerchantRegistrationState get state => _state;
  String? get errorMessage => _errorMessage;
  Merchant? get merchant => _merchant;

  Future<bool> registerMerchant({
    required String email,
    required String password,
    required String legalId,
    required String businessName,
    required String phone,
    required String address,
    required XFile logo,
  }) async {
    _state = MerchantRegistrationState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _merchant = await _registerMerchantUseCase.execute(
        email: email,
        password: password,
        legalId: legalId,
        businessName: businessName,
        phone: phone,
        address: address,
        logo: logo,
      );
      
      _state = MerchantRegistrationState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _state = MerchantRegistrationState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
