import 'dart:convert';

class AmountFormatter {
  /// Formats the total amount from an order object
  /// Uses 'total' field and falls back to 'total_amount' for backward compatibility
  static String formatTotal(Map<String, dynamic> order) {
    if (order.containsKey('total') && order['total'] != null) {
      return formatCurrency(order['total']);
    } else if (order.containsKey('total_amount') && order['total_amount'] != null) {
      return formatCurrency(order['total_amount']);
    }
    return '0.00';
  }
  
  /// Formats a number or string as Costa Rican currency (colones)
  static String formatCurrency(dynamic amount) {
    double numericAmount;
    
    if (amount is String) {
      numericAmount = double.tryParse(amount) ?? 0.0;
    } else if (amount is num) {
      numericAmount = amount.toDouble();
    } else {
      numericAmount = 0.0;
    }
    
    return '₡${numericAmount.toStringAsFixed(2)}';
  }
}
