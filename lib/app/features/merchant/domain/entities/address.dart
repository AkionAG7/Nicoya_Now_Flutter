// lib/app/features/merchant/domain/entities/address.dart

class Address {
  final String addressId;
  final String userId;
  final String street;
  final String district;
  final double lat;
  final double lng;
  final String? note;
  final DateTime createdAt;

  Address({
    required this.addressId,
    required this.userId,
    required this.street,
    required this.district,
    required this.lat,
    required this.lng,
    this.note,
    required this.createdAt,
  });

 factory Address.fromMap(Map<String, dynamic> map) => Address(
        addressId: map['address_id']    as String,
        userId:    map['user_id']       as String,
        street:    map['street']        as String,
        district:  map['district']      as String?  ?? '',
        lat:       (map['lat']          as num?)?.toDouble() ?? 0.0,
        lng:       (map['lng']          as num?)?.toDouble() ?? 0.0,
        note:      map['note']          as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        'address_id' : addressId,
        'user_id'    : userId,
        'street'     : street,
        'district'   : district,
        'lat'        : lat,
        'lng'        : lng,
        'note'       : note,
        'created_at' : createdAt.toIso8601String(),
      };

  Address copyWith({
    String? street,
    String? district,
    double? lat,
    double? lng,
    String? note,
  }) {
    return Address(
      addressId: addressId,
      userId:    userId,
      street:    street    ?? this.street,
      district:  district  ?? this.district,
      lat:       lat       ?? this.lat,
      lng:       lng       ?? this.lng,
      note:      note      ?? this.note,
      createdAt: createdAt,
    );
  }
}
