import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nicoya_now/app/features/merchant/domain/entities/merchant.dart';
import 'package:nicoya_now/app/features/merchant/domain/usecases/register_merchant_usecase.dart';
import 'package:nicoya_now/app/features/auth/presentation/controllers/auth_controller.dart';

enum MerchantRegistrationState { initial, loading, success, error }

class MerchantRegistrationController extends ChangeNotifier {

  MerchantRegistrationController({
    required RegisterMerchantUseCase registerMerchantUseCase,
  }) : _registerMerchantUseCase = registerMerchantUseCase;


  final RegisterMerchantUseCase _registerMerchantUseCase;

 
  MerchantRegistrationState get state        => _state;
  String?                    get errorMessage=> _errorMessage;
  Merchant?                  get merchant    => _merchant;

  MerchantRegistrationState _state = MerchantRegistrationState.initial;
  String?  _errorMessage;
  Merchant? _merchant;
  String? _legalId;
  String? _businessName, _corpName, _address, _logoPath;
  String? _firstName, _last1, _last2, _email, _phone;
  bool _isCedulaJuridica = true;


  void updateBusinessInfo({
    required String legalId,
    required String businessName,
    required String address,
    required XFile  logo,
    String corporateName = '',
    bool isCedulaJuridica = true,
  }) {
    _legalId          = legalId;
    _businessName     = businessName;
    _corpName         = corporateName;
    _address          = address;
    _logoPath         = logo.path;
    _isCedulaJuridica = isCedulaJuridica;
  }

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
  Future<bool> finishRegistration({
    required String password,
    required AuthController authController,
  }) async {
    _state = MerchantRegistrationState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Verificaciones previas para evitar errores de validación
      if (_email == null || _email!.isEmpty) {
        throw Exception("El correo electrónico es obligatorio");
      }
      
      if (_businessName == null || _businessName!.isEmpty) {
        throw Exception("El nombre del negocio es obligatorio");
      }
      
      if (_logoPath == null || _logoPath!.isEmpty) {
        throw Exception("Es necesario subir el logo del negocio");
      }
      
      _merchant = await _registerMerchantUseCase.execute(
        email        : _email!,
        password     : password,
        legalId      : _isCedulaJuridica ? _legalId! : '',
        businessName : _businessName!,
        corporateName: _corpName ?? '',
        phone        : _phone!,
        address      : _address!,
        logoPath     : _logoPath!,
        firstName    : _firstName!,
        lastName1    : _last1!,
        lastName2    : _last2!,
        authController: authController,
        cedula       : _isCedulaJuridica ? null : _legalId,
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
