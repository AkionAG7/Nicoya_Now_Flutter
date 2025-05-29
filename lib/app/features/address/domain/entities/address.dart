import 'dart:ffi';

class Address {
  final String address_id;
  final String user_id;
  final String street;
  final district;
  final Float lat;
  final Float Ing;
  final String note;
  final DateTime created_at;

  Address({
    required this.address_id,
    required this.user_id,
    required this.street,
    required this.district,
    required this.lat,
    required this.Ing,
    required this.note,
    required this.created_at,
  });
}
