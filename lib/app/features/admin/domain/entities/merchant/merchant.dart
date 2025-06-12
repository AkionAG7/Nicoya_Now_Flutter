/// Entity representing a merchant in the system
class Merchant {
  /// Unique identifier for the merchant
  final String merchantId;
  
  /// Name of the merchant's business
  final String businessName;
  
  /// Business address
  final String? address;
  
  /// Business phone number
  final String? phoneNumber;
    /// URL to business documents (optional)
  final String? docsUrl;
  
  /// URL to business logo (optional)
  final String? logoUrl;
  
  /// Business category (e.g., restaurant, retail, etc.)
  final String businessCategory;
  
  /// Whether the merchant has been verified/approved to access the system
  final bool isVerified;
  
  /// When the merchant was created in the system
  final DateTime createdAt;
  /// Creates a new [Merchant] instance
  const Merchant({
    required this.merchantId,
    required this.businessName,
    this.address,
    this.phoneNumber,
    this.docsUrl,
    this.logoUrl,
    required this.businessCategory,
    required this.isVerified,
    required this.createdAt,
  });
  /// Creates a copy of this Merchant with the given fields replaced with new values
  Merchant copyWith({
    String? merchantId,
    String? businessName,
    String? address,
    String? phoneNumber,
    String? docsUrl,
    String? logoUrl,
    String? businessCategory,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    return Merchant(
      merchantId: merchantId ?? this.merchantId,
      businessName: businessName ?? this.businessName,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      docsUrl: docsUrl ?? this.docsUrl,
      logoUrl: logoUrl ?? this.logoUrl,
      businessCategory: businessCategory ?? this.businessCategory,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Merchant &&
        other.merchantId == merchantId &&
        other.businessName == businessName &&
        other.address == address &&
        other.phoneNumber == phoneNumber &&
        other.docsUrl == docsUrl &&
        other.logoUrl == logoUrl &&
        other.businessCategory == businessCategory &&
        other.isVerified == isVerified &&
        other.createdAt == createdAt;
  }
  @override
  int get hashCode {
    return merchantId.hashCode ^
        businessName.hashCode ^
        address.hashCode ^
        phoneNumber.hashCode ^
        docsUrl.hashCode ^
        logoUrl.hashCode ^
        businessCategory.hashCode ^
        isVerified.hashCode ^
        createdAt.hashCode;
  }
  @override
  String toString() {
    return 'Merchant(merchantId: $merchantId, businessName: $businessName, address: $address, phoneNumber: $phoneNumber, docsUrl: $docsUrl, logoUrl: $logoUrl, businessCategory: $businessCategory, isVerified: $isVerified, createdAt: $createdAt)';
  }
}
