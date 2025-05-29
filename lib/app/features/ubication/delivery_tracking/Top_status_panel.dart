import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TopStatusPanel extends StatefulWidget {
  const TopStatusPanel({super.key});

  @override
  State<TopStatusPanel> createState() => _TopStatusPanelState();
}

class _TopStatusPanelState extends State<TopStatusPanel> {
  int currentStep = 1;

  @override
  void initState() {
    super.initState();
    _cambiarPaso();
  }

  void _cambiarPaso() {
    Future.delayed(const Duration(seconds: 10), () {
      if (currentStep < 4) {
        setState(() {
          currentStep++;
        });
        _cambiarPaso(); // Continua hasta el último paso
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Rango de tiempo
    final now = DateTime.now();
    final deliveryEndTime = now.add(const Duration(minutes: 45));
    final timeFormat = DateFormat('h:mm a');
    final String rangoTiempo =
        "${timeFormat.format(now)} - ${timeFormat.format(deliveryEndTime)}";

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tu tiempo de envío",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            "Tiempo estimado $rangoTiempo",
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),

          // Row con íconos y líneas
          Row(
            children: [
              _buildIconStep(Icons.assignment, 1, currentStep),
              _buildDashedLine(currentStep >= 2),
              _buildIconStep(Icons.restaurant, 2, currentStep),
              _buildDashedLine(currentStep >= 3),
              _buildIconStep(Icons.delivery_dining, 3, currentStep),
              _buildDashedLine(currentStep >= 4),
              _buildIconStep(Icons.check_circle_outline, 4, currentStep),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconStep(IconData icon, int step, int currentStep) {
    return Icon(
      icon,
      color: currentStep >= step ? Colors.red : Colors.grey,
      size: 28,
    );
  }

  Widget _buildDashedLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? Colors.red : Colors.grey,
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
        ),
      ),
    );
  }
}
