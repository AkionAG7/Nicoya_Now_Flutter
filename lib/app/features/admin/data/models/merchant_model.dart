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
    return MerchantModel(
      merchantId: json['merchant_id'],
      businessName: json['business_name'],
      address: json['address'],
      phoneNumber: json['phone_number'],
      docsUrl: json['docs_url'],
      businessCategory: json['business_category'],
      isVerified: json['is_verified'],
      createdAt: DateTime.parse(json['created_at']),
    );
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
      'is_verified': isVerified,
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
