import 'package:flutter/material.dart';

/// Widget para los elementos de actividad reciente
class ActivityItem extends StatelessWidget {
  final String title;
  final String description;
  final String time;
  final IconData icon;

  const ActivityItem({
    super.key,
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFE60023).withAlpha(51),
        child: Icon(icon, color: const Color(0xFFE60023)),
      ),
      title: Text(title),
      subtitle: Text(description),
      trailing: Text(time, style: TextStyle(color: Colors.grey[600])),
    );
  }
}
