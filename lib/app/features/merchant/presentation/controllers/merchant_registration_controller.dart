import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nicoya_now/app/features/merchant/domain/entities/merchant.dart';
import 'package:nicoya_now/app/features/merchant/domain/usecases/register_merchant_usecase.dart';

// ────────────────────────────────────────────────────────────
//  ESTADOS
// ────────────────────────────────────────────────────────────
enum MerchantRegistrationState { initial, loading, success, error }

// ────────────────────────────────────────────────────────────
//  CONTROLLER
// ────────────────────────────────────────────────────────────
class MerchantRegistrationController extends ChangeNotifier {
  // ------------ constructor -------------
  /// ❶  **El parámetro se llama exactamente igual** que en tu service locator
  MerchantRegistrationController({
    required RegisterMerchantUseCase registerMerchantUseCase,
  }) : _registerMerchantUseCase = registerMerchantUseCase;

  // ------------ dependencias ------------
  final RegisterMerchantUseCase _registerMerchantUseCase;

  // ------------ estado público ----------
  MerchantRegistrationState get state        => _state;
  String?                    get errorMessage=> _errorMessage;
  Merchant?                  get merchant    => _merchant;

  // ------------ estado interno ----------
  MerchantRegistrationState _state = MerchantRegistrationState.initial;
  String?  _errorMessage;
  Merchant? _merchant;

  // ------------ datos acumulados --------
  String? _legalId;
  String? _businessName, _corpName, _address, _logoPath;
  String? _firstName, _last1, _last2, _email, _phone;

  // ──────────────────────────────────
  //  Paso 1 – datos del comercio
  // ──────────────────────────────────
  void updateBusinessInfo({
    required String legalId,
    required String businessName,
    required String address,
    required XFile  logo,
    String corporateName = '',
  }) {
    _legalId      = legalId;
    _businessName = businessName;
    _corpName     = corporateName;
    _address      = address;
    _logoPath     = logo.path;    
  }

  // ──────────────────────────────────
  //  Paso 2 – datos del encargado
  // ──────────────────────────────────
  void updateOwnerInfo({
    required String firstName,
    required String lastName1,
    required String lastName2,
    required String email,
    required String phone,
  }) {
    _firstName = firstName;
    _last1     = lastName1;
    _last2     = lastName2;
    _email     = email;
    _phone     = phone;
  }

  Future<bool> finishRegistration({required String password}) async {
    _state = MerchantRegistrationState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _merchant = await _registerMerchantUseCase.execute(
        email        : _email!,
        password     : password,
        legalId      : _legalId!,
        businessName : _businessName!,
        corporateName: _corpName ?? '',
        phone        : _phone!,
        address      : _address!,
        logoPath     : _logoPath!,
        firstName    : _firstName!,
        lastName1    : _last1!,
        lastName2    : _last2!,
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
