
import 'package:image_picker/image_picker.dart';

class MerchantFormData {
  final String legalId;
  final String name;
  final String phone;
  final String address;
  final String email;
  final String password;
  final XFile? logo;

  MerchantFormData({
    required this.legalId,
    required this.name,
    required this.phone,
    required this.address,
    required this.email,
    required this.password,
    this.logo,
  });
}
