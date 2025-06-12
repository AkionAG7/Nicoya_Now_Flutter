
import 'package:postgrest/src/types.dart';

class Address {
  final String address_id;
  final String user_id;
  final String street;
  final String district;
  final double lat;
  final double lng;
  final String note;
  final DateTime created_at;

  Address({
    required this.address_id,
    required this.user_id,
    required this.street,
    required this.district,
    required this.lat,
    required this.lng,
    required this.note,
    required this.created_at,
  });
  static Address empty() {
    return Address(
      address_id: '',
      user_id: '',
      street: '',
      district: '',
      lat: 0.0,
      lng: 0.0,
      note: '',
      created_at: DateTime.now(),
    );
  }

  static Address fromMap(PostgrestMap addressJson) {
    return Address(
      address_id: addressJson['address_id'] as String? ?? '',
      user_id: addressJson['user_id'] as String? ?? '',
      street: addressJson['street'] as String? ?? '',
      district: addressJson['district'] as String? ?? '',
      lat: (addressJson['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (addressJson['lng'] as num?)?.toDouble() ?? 0.0,
      note: addressJson['note'] as String? ?? '',
      created_at: addressJson['created_at'] != null 
          ? DateTime.parse(addressJson['created_at'].toString())
          : DateTime.now(),
    );
  }
}
