
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

  static empty() {}

  static fromMap(PostgrestMap addressJson) {}
}
