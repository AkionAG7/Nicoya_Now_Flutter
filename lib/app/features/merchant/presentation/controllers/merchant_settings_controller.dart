import 'package:flutter/foundation.dart';
import 'package:nicoya_now/app/features/merchant/domain/usecases/get_merchant_byowner_usecase.dart';
import '../../domain/entities/merchant.dart';

enum MerchantSettingsState { initial, loading, loaded, error }

class MerchantSettingsController extends ChangeNotifier {
  final GetMerchantByOwnerUseCase _getUseCase;

  MerchantSettingsController(this._getUseCase);

  MerchantSettingsState _state = MerchantSettingsState.initial;
  MerchantSettingsState get state => _state;

  Merchant? _merchant;
  Merchant? get merchant => _merchant;

  String? _error;
  String? get error => _error;

  Future<void> load(String ownerId) async {
    _state = MerchantSettingsState.loading;
    notifyListeners();

    try {
      _merchant = await _getUseCase.call(ownerId);
      _state = MerchantSettingsState.loaded;
    } catch (e) {
      _error = e.toString();
      _state = MerchantSettingsState.error;
    }

    notifyListeners();
  }
}
