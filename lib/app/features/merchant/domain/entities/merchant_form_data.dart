import 'package:image_picker/image_picker.dart';

class MerchantBusinessFormData {
  final String legalId;
  final String businessName;
  final String? corporateName;
  final String address;        
  final XFile logo;              

  MerchantBusinessFormData({
    required this.legalId,
    required this.businessName,
    this.corporateName,
    required this.address,
    required this.logo,
  });
}
