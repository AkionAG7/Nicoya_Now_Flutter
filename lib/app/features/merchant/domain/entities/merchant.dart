class Merchant {
  final String merchantId;
  final String ownerId;
  final String legalId;
  final String businessName;
  final String? corporateName;      // 👈  NUEVO  (puede ser null)
  final String logoUrl;
  final String mainAddressId;
  final bool   isActive;
  final DateTime createdAt;         // 👈  NUEVO  (timestamp)

  Merchant({
    required this.merchantId,
    required this.ownerId,
    required this.legalId,
    required this.businessName,
    this.corporateName,             // opcional
    required this.logoUrl,
    required this.mainAddressId,
    required this.isActive,
    required this.createdAt,
  });

  /* Helpers para serializar --------------------------------------------- */
  factory Merchant.fromMap(Map<String, dynamic> map) => Merchant(
        merchantId     : map['merchant_id']    as String,
        ownerId        : map['owner_id']       as String,
        legalId        : map['legal_id']       as String,
        businessName   : map['business_name']  as String,
        corporateName  : map['corporate_name'] as String?,
        logoUrl        : map['logo_url']       as String,
        mainAddressId  : map['main_address_id']as String,
        isActive       : map['is_active']      as bool,
        createdAt      : DateTime.parse(map['created_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        'merchant_id'     : merchantId,
        'owner_id'        : ownerId,
        'legal_id'        : legalId,
        'business_name'   : businessName,
        'corporate_name'  : corporateName,
        'logo_url'        : logoUrl,
        'main_address_id' : mainAddressId,
        'is_active'       : isActive,
        'created_at'      : createdAt.toIso8601String(),
      };
}
