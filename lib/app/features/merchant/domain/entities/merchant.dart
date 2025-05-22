class Merchant {
  final String merchantId;
  final String ownerId;
  final String legalId;
  final String businessName;
  final String logoUrl;
  final String mainAddressId;
  final bool isActive;

  Merchant({
    required this.merchantId,
    required this.ownerId,
    required this.legalId,
    required this.businessName,
    required this.logoUrl,
    required this.mainAddressId,
    required this.isActive,
  });
}
