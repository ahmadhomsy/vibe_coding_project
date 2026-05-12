import 'package:flutter/material.dart';
import 'package:software_engineering_project/features/canvas/domain/models/node_model.dart';
import 'package:software_engineering_project/features/canvas/domain/models/node_type.dart';

class NodeWidget extends StatelessWidget {
  const NodeWidget({
    super.key,
    required this.node,
    required this.isSelected,
    required this.isConnecting,
    required this.onTap,
    required this.onDrag,
    required this.onPortTap,
    required this.onDelete,
  });

  final NodeModel node;
  final bool isSelected;
  final bool isConnecting;
  final VoidCallback onTap;
  final void Function(Offset) onDrag;
  final void Function(bool isOutput) onPortTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final borderColor = _getNodeColor();

    return Positioned(
      left: node.position.dx,
      top: node.position.dy,
      child: GestureDetector(
        onPanUpdate: (details) => onDrag(node.position + details.delta),
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 180,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: isSelected
                      ? Colors.white
                      : borderColor.withValues(alpha: 0.5),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(borderColor),
                  _buildContent(),
                ],
              ),
            ),
            if (node.type != NodeType.trigger)
              Positioned(
                left: -8,
                top: 50,
                child: _Port(
                  isOutput: false,
                  onTap: () => onPortTap(false),
                  color: Colors.white30,
                ),
              ),
            Positioned(
              right: -8,
              top: 50,
              child: _Port(
                isOutput: true,
                onTap: () => onPortTap(true),
                color: isConnecting ? Colors.white : borderColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getNodeColor() {
    switch (node.type) {
      case NodeType.log:
        return const Color(0xFF6366F1);
      case NodeType.color:
        return const Color(0xFF10B981);
      case NodeType.delay:
        return Colors.orangeAccent;
      case NodeType.name:
        return const Color(0xFFF43F5E);
      case NodeType.age:
        return const Color(0xFFF59E0B);
      case NodeType.address:
        return const Color(0xFF8B5CF6);
      case NodeType.date:
        return const Color(0xFF06B6D4);
      case NodeType.email:
        return const Color(0xFFEC4899);
      case NodeType.trigger:
        return const Color(0xFF10B981);
    }
  }

  Widget _buildHeader(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: Row(
        children: [
          Icon(_getIcon(), size: 14, color: Colors.white70),
          const SizedBox(width: 8),
          Text(
            node.type.name.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.close, size: 14, color: Colors.white30),
          ),
        ],
      ),
    );
  }

  IconData _getIcon() {
    switch (node.type) {
      case NodeType.log:
        return Icons.terminal;
      case NodeType.color:
        return Icons.palette;
      case NodeType.delay:
        return Icons.timer;
      case NodeType.name:
        return Icons.person;
      case NodeType.age:
        return Icons.cake;
      case NodeType.address:
        return Icons.home;
      case NodeType.date:
        return Icons.calendar_today;
      case NodeType.email:
        return Icons.email;
      case NodeType.trigger:
        return Icons.bolt;
    }
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (node.type == NodeType.log)
            Text(
              node.logText,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          if (node.type == NodeType.color)
            Container(
              height: 20,
              decoration: BoxDecoration(
                color: node.colorValue,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          if (node.type == NodeType.delay)
            Text(
              '${node.delayMs}ms',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          if (node.type == NodeType.name)
            Text(
              node.name.isEmpty ? 'No Name' : node.name,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          if (node.type == NodeType.age)
            Text(
              node.age.isEmpty ? 'No Age' : node.age,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          if (node.type == NodeType.address)
            Text(
              node.address.isEmpty ? 'No Address' : node.address,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          if (node.type == NodeType.date)
            Text(
              node.date.isEmpty ? 'No Date' : node.date,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          if (node.type == NodeType.email)
            Text(
              node.email.isEmpty ? 'No Email' : node.email,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          if (node.type == NodeType.trigger)
            Text(
              node.triggerName,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}

class _Port extends StatelessWidget {
  const _Port({
    required this.isOutput,
    required this.onTap,
    required this.color,
  });
  final bool isOutput;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Center(
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}
