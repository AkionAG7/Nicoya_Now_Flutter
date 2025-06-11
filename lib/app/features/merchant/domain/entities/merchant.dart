// lib/app/features/merchant/domain/entities/merchant.dart

import 'address.dart';  // <-- asegúrate de tener este import

class Merchant {
  final String merchantId;
  final String ownerId;
  final String legalId;
  final String businessName;
  final String? corporateName;    
  final String logoUrl;
  final String mainAddressId;
  final bool   isActive;
  final DateTime createdAt;

  /// Dirección principal completa
  final Address mainAddress;       // <-- campo añadido

  Merchant({
    required this.merchantId,
    required this.ownerId,
    required this.legalId,
    required this.businessName,
    this.corporateName,             
    required this.logoUrl,
    required this.mainAddressId,
    required this.isActive,
    required this.createdAt,
    required this.mainAddress,      // <-- parámetro añadido
  });

  factory Merchant.fromMap(Map<String, dynamic> map) => Merchant(
        merchantId     : map['merchant_id']     as String,
        ownerId        : map['owner_id']        as String,
        legalId        : map['legal_id']        as String,
        businessName   : map['business_name']   as String,
        corporateName  : map['corporate_name']  as String?,
        logoUrl        : map['logo_url']        as String,
        mainAddressId  : map['main_address_id'] as String,
        isActive       : map['is_active']       as bool,
        createdAt      : DateTime.parse(map['created_at'] as String),
        mainAddress    : Address.fromMap(       // <-- parsear dirección anidada
                          map['main_address'] 
                            as Map<String, dynamic>
                        ),
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
        'main_address'    : mainAddress.toMap(), // <-- serializar dirección
      };

  Merchant copyWith({
    String? businessName,
    String? logoUrl,
    String? mainAddressId,
    Address? mainAddress,              // <-- permitir reemplazar la dirección
    bool?   isActive,
  }) {
    return Merchant(
      merchantId    : merchantId,
      ownerId       : ownerId,
      legalId       : legalId,
      businessName  : businessName  ?? this.businessName,
      corporateName : corporateName,
      logoUrl       : logoUrl       ?? this.logoUrl,
      mainAddressId : mainAddressId ?? this.mainAddressId,
      isActive      : isActive      ?? this.isActive,
      createdAt     : createdAt,
      mainAddress   : mainAddress   ?? this.mainAddress,
    );
  }
}
