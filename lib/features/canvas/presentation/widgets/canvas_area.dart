import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_engineering_project/core/theme/app_colors.dart';
import 'package:software_engineering_project/features/canvas/domain/models/node_type.dart';
import 'package:software_engineering_project/features/canvas/logic/automation_cubit.dart';
import 'package:software_engineering_project/features/canvas/presentation/painters/connection_painter.dart';
import 'package:software_engineering_project/features/canvas/presentation/painters/grid_painter.dart';
import 'package:software_engineering_project/features/canvas/presentation/widgets/node_widget.dart';

class CanvasAreaWidget extends StatelessWidget {
  const CanvasAreaWidget({
    required this.controller,
    super.key,
  });
  final AutomationCubit controller;

  @override
  Widget build(BuildContext context) {
    return DragTarget<NodeType>(
      onAcceptWithDetails: (details) {
        final renderBox = context.findRenderObject()! as RenderBox;
        final localPos = renderBox.globalToLocal(details.offset);
        final adjustedPos = Offset(localPos.dx, localPos.dy);
        controller.addNode(details.data, adjustedPos);
      },
      builder: (context, candidateData, rejectedData) {
        return BlocBuilder<AutomationCubit, AutomationState>(
          builder: (context, state) {
            return ColoredBox(
              color: AppColors.background,
              child: ClipRect(
                child: Stack(
                  children: [
                    Positioned.fill(child: CustomPaint(painter: GridPainter())),
                    Positioned.fill(
                      child: CustomPaint(
                        painter: ConnectionPainter(
                          nodes: state.nodes,
                          connections: state.connections,
                        ),
                      ),
                    ),
                    ...state.nodes.map(
                      (node) => NodeWidget(
                        key: ValueKey(node.id),
                        node: node,
                        isSelected: state.selectedNode == node,
                        isConnecting: state.selectedPortNodeId == node.id,
                        onTap: () => controller.selectNode(node),
                        onDrag: (newPos) =>
                            controller.updateNodePosition(node, newPos),
                        onPortTap: (isOutput) =>
                            controller.handlePortClick(node.id, isOutput),
                        onDelete: () => controller.deleteNode(node.id),
                      ),
                    ),
                    if (candidateData.isNotEmpty)
                      Positioned.fill(
                        child: ColoredBox(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          child: const Center(
                            child: Text(
                              'DROP TO ADD NODE',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
