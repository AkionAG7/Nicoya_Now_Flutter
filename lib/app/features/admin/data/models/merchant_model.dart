import '../../domain/entities/merchant/merchant.dart';

/// Data model for a [Merchant] entity
class MerchantModel extends Merchant {
  /// Creates a new [MerchantModel] instance
  const MerchantModel({
    required super.merchantId,
    required super.businessName,
    super.address,
    super.phoneNumber,
    super.docsUrl,
    required super.businessCategory,
    required super.isVerified,
    required super.createdAt,
  });
  
  /// Creates a [MerchantModel] from a JSON map
  factory MerchantModel.fromJson(Map<String, dynamic> json) {
    // Defensive parsing to handle potentially missing or invalid data
    try {      // Check for is_active field to determine verification status
      // For tab separation in admin panel:
      // - is_active = false → merchant is NOT yet approved (pending approval), show in "Por Aprobar" tab
      // - is_active = true → merchant IS approved, show in "Aprobados" tab
      // We use !is_active because the tabs are: [0] = pending (not approved), [1] = approved
      final bool isVerificationStatus = json['is_active'] == true;
      
      return MerchantModel(
        merchantId: json['merchant_id']?.toString() ?? 'unknown',
        businessName: json['business_name']?.toString() ?? 'Unknown Business',
        address: json['address']?.toString(),
        phoneNumber: json['phone_number']?.toString(),
        docsUrl: json['docs_url']?.toString(),
        businessCategory: json['business_category']?.toString() ?? 'other',
        isVerified: isVerificationStatus,
        createdAt: json['created_at'] != null 
            ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );
    } catch (e) {
      print('Error in MerchantModel.fromJson: $e');
      print('JSON data: $json');
      rethrow;
    }
  }
  /// Converts this model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'merchant_id': merchantId,
      'business_name': businessName,
      'address': address,
      'phone_number': phoneNumber,
      'docs_url': docsUrl,
      'business_category': businessCategory,
      'is_active': isVerified,
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  /// Creates a model from an entity
  factory MerchantModel.fromEntity(Merchant merchant) {
    return MerchantModel(
      merchantId: merchant.merchantId,
      businessName: merchant.businessName,
      address: merchant.address,
      phoneNumber: merchant.phoneNumber,
      docsUrl: merchant.docsUrl,
      businessCategory: merchant.businessCategory,
      isVerified: merchant.isVerified,
      createdAt: merchant.createdAt,
    );
  }
}
