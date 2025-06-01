import 'package:flutter/material.dart';
import 'package:nicoya_now/app/features/driver/presentation/controllers/driver_controller.dart';
import 'package:nicoya_now/app/features/driver/presentation/widgets/order_card.dart';

class ActiveOrdersTabWidget extends StatelessWidget {
  final DriverController controller;

  const ActiveOrdersTabWidget({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (controller.activeOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hourglass_empty,
              size: 72,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay entregas activas',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => controller.loadActiveOrders(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE60023),
              ),
              child: const Text(
                'Actualizar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () => controller.loadActiveOrders(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: controller.activeOrders.length,
        itemBuilder: (context, index) {
          final order = controller.activeOrders[index];
          return OrderCard(order: order);
        },
      ),
    );
  }
}
