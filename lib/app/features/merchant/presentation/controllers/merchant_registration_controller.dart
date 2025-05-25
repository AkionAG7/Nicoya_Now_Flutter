import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:nicoya_now/app/features/merchant/domain/entities/merchant.dart';
import 'package:nicoya_now/app/features/merchant/domain/usecases/register_merchant_usecase.dart';
import 'package:nicoya_now/app/features/auth/presentation/controllers/auth_controller.dart';

enum MerchantRegistrationState { initial, loading, success, error }

class MerchantRegistrationController extends ChangeNotifier {

  MerchantRegistrationController({
    required RegisterMerchantUseCase registerMerchantUseCase,
    required AuthController authController,
  }) : _registerMerchantUseCase = registerMerchantUseCase,
       _authController = authController;


  final RegisterMerchantUseCase _registerMerchantUseCase;
  final AuthController _authController;

   MerchantRegistrationState get state        => _state;
  String?                    get errorMessage=> _errorMessage;
  Merchant?                  get merchant    => _merchant;
  
  // Getters para acceder a los datos del formulario
  String? get firstName => _firstName;
  String? get lastName1 => _last1;
  String? get lastName2 => _last2;
  String? get email => _email;
  String? get phone => _phone;

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
    Future<bool> finishRegistration({required String password, bool isAddingRole = false}) async {
    _state = MerchantRegistrationState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      if (isAddingRole) {
        return await _addMerchantRole();
      } else {
        return await _performFullRegistration(password);
      }
    } catch (e) {
      _state = MerchantRegistrationState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> _performFullRegistration(String password) async {
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
      cedula       : _isCedulaJuridica ? null : _legalId,
    );

    _state = MerchantRegistrationState.success;
    notifyListeners();
    return true;
  }  Future<bool> _addMerchantRole() async {
    print('🔍 [MerchantController] Intentando agregar rol merchant...');
    print('🔍 [MerchantController] Estado de AuthController: ${_authController.state}');
    print('🔍 [MerchantController] Sesión activa: ${_authController.hasActiveSession}');
    
    final user = _authController.user;
    print('🔍 [MerchantController] Usuario en sesión: ${user?.id ?? "null"}');
    print('🔍 [MerchantController] Email del usuario: ${user?.email ?? "null"}');
    
    if (user == null) {
      print('❌ [MerchantController] ERROR: No hay sesión activa');
      print('❌ [MerchantController] Estado AuthController: ${_authController.state}');
      print('❌ [MerchantController] Error message: ${_authController.errorMessage}');
      throw Exception('No hay sesión activa');
    }

    print('✅ [MerchantController] Sesión activa encontrada para usuario: ${user.id}');
    print('🔄 [MerchantController] Creando datos de merchant...');

    // Crear el registro de merchant directamente en Supabase para usuario existente
    await _createMerchantDataForExistingUser(user.id);

    print('🔄 [MerchantController] Agregando rol merchant...');
    
    // Agregar rol de merchant en la base de datos usando solo AuthController
    await _authController.addRole('merchant');
    
    print('✅ [MerchantController] Rol merchant agregado exitosamente');
    
    _state = MerchantRegistrationState.success;
    notifyListeners();
    return true;
  }

  Future<void> _createMerchantDataForExistingUser(String userId) async {
    // Necesitamos acceso directo a Supabase para crear solo los datos del merchant
    // sin crear un nuevo usuario
    final supa = GetIt.I<SupabaseClient>();
    
    // Crear address
    final addr = await supa.from('address').insert({
      'user_id': userId,
      'street' : _address!,
      'district': '',
    }).select('address_id').single();
    final addressId = addr['address_id'] as String;

    // Subir logo
    final ext = _logoPath!.split('.').last;
    final path = 'merchant/$userId/logo.$ext';

    if (kIsWeb) {
      final bytes = await File(_logoPath!).readAsBytes();
      await supa.storage.from('merchant-assets')
          .uploadBinary(path, bytes,
            fileOptions: const FileOptions(upsert: true));
    } else {
      await supa.storage.from('merchant-assets')
          .upload(path, File(_logoPath!),
            fileOptions: const FileOptions(upsert: true));
    }

    final publicUrl = supa.storage.from('merchant-assets').getPublicUrl(path);

    // Crear registro merchant
    final merchantData = await supa.from('merchant').insert({
      'merchant_id'    : userId,
      'owner_id'       : userId,
      'legal_id'       : _isCedulaJuridica ? _legalId! : '',
      'business_name'  : _businessName!,
      'corporate_name' : _corpName ?? '',
      'logo_url'       : publicUrl,
      'main_address_id': addressId,
      'is_active'      : false,
    }).select().single();

    // Crear entidad Merchant
    _merchant = Merchant.fromMap(merchantData);
  }  void fillExistingUserData() {
    final user = _authController.user;
    print('🔄 [MerchantController] Llenando datos del usuario existente...');
    
    if (user != null) {
      _firstName = user.firstName ?? '';
      _last1 = user.lastName1 ?? '';
      _last2 = user.lastName2 ?? '';
      _email = user.email;
      _phone = user.phone ?? '';
      
      print('✅ [MerchantController] Datos cargados:');
      print('   - firstName: "$_firstName"');
      print('   - lastName1: "$_last1"');
      print('   - lastName2: "$_last2"');
      print('   - email: "$_email"');
      print('   - phone: "$_phone"');
      
      // Notificar a los listeners que los datos han cambiado
      notifyListeners();
      print('🔔 [MerchantController] Listeners notificados');
    } else {
      print('❌ [MerchantController] No hay usuario autenticado para prellenar datos');
    }
  }
}
