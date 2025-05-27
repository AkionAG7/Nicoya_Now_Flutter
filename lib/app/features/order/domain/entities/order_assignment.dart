class OrderAssignment {
  String order_id;
  String driver_id;
  DateTime assigned_at;
  DateTime pciekd_up_at;
  DateTime delivered_at;

  OrderAssignment({
    required this.order_id,
    required this.driver_id,
    required this.assigned_at,
    required this.pciekd_up_at,
    required this.delivered_at,
  });
}
