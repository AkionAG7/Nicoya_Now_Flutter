import 'package:flutter/material.dart';

/// Widget para los elementos de la lista de comerciantes
class MerchantListItem extends StatelessWidget {
  final String name;
  final String status;
  final VoidCallback onApprove;
  final VoidCallback? onUnapprove;
  final VoidCallback? onViewDetails;
  final bool isApproved;  const MerchantListItem({
    super.key,
    required this.name,
    required this.status,
    required this.onApprove,
    this.onUnapprove,
    this.onViewDetails,
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
        subtitle: Text('Estado: $status'),        trailing: isApproved
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified, color: Colors.green),
                  const SizedBox(width: 8),
                  if (onViewDetails != null) ...[
                    IconButton(
                      onPressed: onViewDetails,
                      icon: const Icon(Icons.info_outline),
                      color: Colors.blue,
                      tooltip: 'Ver más',
                    ),
                    const SizedBox(width: 4),
                  ],
                  if (onUnapprove != null)
                    ElevatedButton(
                      onPressed: onUnapprove,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Suspender'),
                    ),
                ],
              )            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onViewDetails != null) ...[
                    IconButton(
                      onPressed: onViewDetails,
                      icon: const Icon(Icons.info_outline),
                      color: Colors.blue,
                      tooltip: 'Ver más',
                    ),
                    const SizedBox(width: 4),
                  ],
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
