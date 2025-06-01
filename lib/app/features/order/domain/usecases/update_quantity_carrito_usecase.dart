class UpdateQuantityCarrito{
  List<Map<String,dynamic>> call ({
    required List<Map<String, dynamic>> items,
    required int index,
    required bool increment,
  }) {
    final updateItems = List<Map<String, dynamic>>.from(items);
    final current = updateItems[index];
    int cantidad = current['quantity'] ?? 1;
    if (increment) {
      cantidad++;
    } else {
      if (cantidad > 1) {
        cantidad--;
      }
    }
    updateItems[index]['quantity'] = cantidad;
    return updateItems;
  }
}