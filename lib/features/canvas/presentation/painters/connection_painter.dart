import 'package:flutter/material.dart';
import 'package:software_engineering_project/features/canvas/domain/models/connection.dart';
import 'package:software_engineering_project/features/canvas/domain/models/node_model.dart';

class ConnectionPainter extends CustomPainter {
  ConnectionPainter({required this.nodes, required this.connections});
  final List<NodeModel> nodes;
  final List<Connection> connections;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6366F1).withValues(alpha: 0.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (final conn in connections) {
      final fromNode = nodes.firstWhere(
        (n) => n.id == conn.fromNodeId,
        orElse: () => nodes.first,
      );
      final toNode = nodes.firstWhere(
        (n) => n.id == conn.toNodeId,
        orElse: () => nodes.first,
      );

      // Node width is 180, port is at top 50
      final start = Offset(
        fromNode.position.dx + 180,
        fromNode.position.dy + 58,
      );
      final end = Offset(toNode.position.dx, toNode.position.dy + 58);

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(
          start.dx + 50,
          start.dy,
          end.dx - 50,
          end.dy,
          end.dx,
          end.dy,
        );

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
