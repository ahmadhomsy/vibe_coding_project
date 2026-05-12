import 'package:flutter/material.dart';
import 'package:software_engineering_project/features/canvas/domain/models/node_type.dart';

class DraggableSidebarItem extends StatelessWidget {
  const DraggableSidebarItem({
    required this.title,
    required this.icon,
    required this.type,
    required this.onTap,
    required this.color,
    super.key,
  });
  final String title;
  final IconData icon;
  final NodeType type;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final item = SidebarItem(
      title: title,
      icon: icon,
      onTap: onTap,
      color: color,
    );

    return Draggable<NodeType>(
      data: type,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: 180,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: item),
      child: item,
    );
  }
}

class SidebarItem extends StatelessWidget {
  const SidebarItem({
    required this.title,
    required this.icon,
    required this.onTap,
    required this.color,
    super.key,
  });
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
