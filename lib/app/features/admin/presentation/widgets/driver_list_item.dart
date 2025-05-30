import 'package:flutter/material.dart';

/// Widget para los elementos de la lista de repartidores
class DriverListItem extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final String status;
  final VoidCallback onApprove;
  final VoidCallback? onReject;
  final bool isApproved;

  const DriverListItem({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.status,
    required this.onApprove,
    this.onReject,
    this.isApproved = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE60023),
          child: Icon(Icons.delivery_dining, color: Colors.white),
        ),
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: $email'),
            Text('Teléfono: $phone'),
            Text('Estado: $status'),
          ],
        ),
        isThreeLine: true,
        trailing: isApproved
            ? const Icon(Icons.verified, color: Colors.green)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onReject != null)
                    IconButton(
                      onPressed: onReject,
                      icon: const Icon(Icons.close),
                      color: Colors.red,
                      tooltip: 'Rechazar',
                    ),
                  ElevatedButton(
                    onPressed: onApprove,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE60023),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Aprobar'),
                  ),
                ],
              ),
      ),
    );
  }
}
