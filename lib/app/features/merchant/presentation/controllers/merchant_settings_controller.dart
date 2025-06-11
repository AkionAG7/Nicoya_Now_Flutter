// lib/app/features/merchant/presentation/controllers/merchant_settings_controller.dart

import 'package:flutter/foundation.dart';
import 'package:nicoya_now/app/features/merchant/domain/usecases/update_merchant_address_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/merchant.dart';
import '../../domain/entities/address.dart';
import '../../domain/usecases/get_merchant_byowner_usecase.dart';

enum MerchantSettingsState { initial, loading, loaded, error }

class MerchantSettingsController extends ChangeNotifier {
  final GetMerchantByOwnerUseCase _getUseCase;
  final UpdateMerchantAddress _updateUseCase;

  MerchantSettingsController(this._getUseCase, this._updateUseCase);

  MerchantSettingsState _state = MerchantSettingsState.initial;
  MerchantSettingsState get state => _state;

  Merchant? _merchant;
  Merchant? get merchant => _merchant;

  String? _error;
  String? get error => _error;

  /// Carga el merchant (incluyendo mainAddress) para el owner autenticado
  Future<void> load() async {
    _state = MerchantSettingsState.loading;
    notifyListeners();

    try {
      final ownerId = Supabase.instance.client.auth.currentUser!.id;
      _merchant = await _getUseCase.call(ownerId);
      _state = MerchantSettingsState.loaded;
    } catch (e) {
      _error = e.toString();
      _state = MerchantSettingsState.error;
    }

    notifyListeners();
  }

  /// Actualiza la dirección principal y refresca el merchant
  Future<void> saveAddress(Address newAddress) async {
    if (_merchant == null) return;

    _state = MerchantSettingsState.loading;
    notifyListeners();

    try {
      // Creamos un Merchant con la nueva dirección en memoria
      final updated = _merchant!.copyWith(mainAddress: newAddress);

      // Persistimos el cambio
      final result = await _updateUseCase.call(updated);

      // Actualizamos el estado con el merchant resultante
      _merchant = result;
      _state = MerchantSettingsState.loaded;
    } catch (e) {
      _error = e.toString();
      _state = MerchantSettingsState.error;
    }

    notifyListeners();
  }
}
