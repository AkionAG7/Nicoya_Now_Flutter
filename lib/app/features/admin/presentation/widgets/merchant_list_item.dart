import 'package:flutter/material.dart';

/// Widget para los elementos de la lista de comerciantes
class MerchantListItem extends StatelessWidget {
  final String name;
  final String status;
  final VoidCallback onApprove;
  final bool isApproved;

  const MerchantListItem({
    super.key,
    required this.name,
    required this.status,
    required this.onApprove,
    this.isApproved = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.store),
        ),
        title: Text(name),
        subtitle: Text('Estado: $status'),
        trailing: isApproved
            ? const Icon(Icons.verified, color: Colors.green)
            : ElevatedButton(
                onPressed: onApprove,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE60023),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Aprobar'),
              ),
      ),
    );
  }
}
