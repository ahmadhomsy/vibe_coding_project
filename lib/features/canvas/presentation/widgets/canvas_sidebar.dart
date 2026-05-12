import 'package:flutter/material.dart';
import 'package:software_engineering_project/core/theme/app_colors.dart';
import 'package:software_engineering_project/features/canvas/domain/models/node_type.dart';
import 'package:software_engineering_project/features/canvas/logic/automation_cubit.dart';
import 'package:software_engineering_project/features/canvas/presentation/bloc/canvas_ui_cubit.dart';
import 'package:software_engineering_project/features/canvas/presentation/widgets/properties_panel.dart';
import 'package:software_engineering_project/features/canvas/presentation/widgets/sidebar_item.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CanvasSidebar extends StatelessWidget {
  final AutomationCubit controller;
  final CanvasUiCubit uiCubit;

  const CanvasSidebar({
    super.key,
    required this.controller,
    required this.uiCubit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          right: BorderSide(color: AppColors.text.withValues(alpha: 0.1)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'NODE BOX',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => uiCubit.setSidebarOpen(false),
                tooltip: 'Close Sidebar',
              ),
            ],
          ),
          BlocBuilder<AutomationCubit, AutomationState>(
            builder: (context, state) {
              return Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    DraggableSidebarItem(
                      title: 'Trigger Node',
                      icon: Icons.bolt,
                      type: NodeType.trigger,
                      onTap: () => controller.addNode(NodeType.trigger),
                      color: AppColors.secondary,
                    ),
                    const SizedBox(height: 12),
                    DraggableSidebarItem(
                      title: 'Log Node',
                      icon: Icons.terminal,
                      type: NodeType.log,
                      onTap: () => controller.addNode(NodeType.log),
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    DraggableSidebarItem(
                      title: 'Color Node',
                      icon: Icons.palette,
                      type: NodeType.color,
                      onTap: () => controller.addNode(NodeType.color),
                      color: AppColors.secondary,
                    ),
                    const SizedBox(height: 12),
                    DraggableSidebarItem(
                      title: 'Delay Node',
                      icon: Icons.timer,
                      type: NodeType.delay,
                      onTap: () => controller.addNode(NodeType.delay),
                      color: Colors.orangeAccent,
                    ),
                    const SizedBox(height: 12),
                    DraggableSidebarItem(
                      title: 'Name Node',
                      icon: Icons.person,
                      type: NodeType.name,
                      onTap: () => controller.addNode(NodeType.name),
                      color: const Color(0xFFF43F5E),
                    ),
                    const SizedBox(height: 12),
                    DraggableSidebarItem(
                      title: 'Age Node',
                      icon: Icons.cake,
                      type: NodeType.age,
                      onTap: () => controller.addNode(NodeType.age),
                      color: const Color(0xFFF59E0B),
                    ),
                    const SizedBox(height: 12),
                    DraggableSidebarItem(
                      title: 'Address Node',
                      icon: Icons.home,
                      type: NodeType.address,
                      onTap: () => controller.addNode(NodeType.address),
                      color: const Color(0xFF8B5CF6),
                    ),
                    const SizedBox(height: 12),
                    DraggableSidebarItem(
                      title: 'Date Node',
                      icon: Icons.calendar_today,
                      type: NodeType.date,
                      onTap: () => controller.addNode(NodeType.date),
                      color: const Color(0xFF06B6D4),
                    ),
                    const SizedBox(height: 12),
                    DraggableSidebarItem(
                      title: 'Email Node',
                      icon: Icons.email,
                      type: NodeType.email,
                      onTap: () => controller.addNode(NodeType.email),
                      color: const Color(0xFFEC4899),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: state.isRunning
                          ? null
                          : controller.runAutomation,
                      icon: state.isRunning
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.play_arrow, color: Colors.white),
                      label: Text(
                        state.isRunning ? 'EXECUTING...' : 'RUN AUTOMATION',
                        style: const TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        final json = controller.saveProject();
                        print('SAVED JSON: $json');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Project saved to console (JSON)'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('SAVE PROJECT'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: controller.clearCanvas,
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.error,
                      ),
                      label: const Text(
                        'CLEAR CANVAS',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          BlocBuilder<AutomationCubit, AutomationState>(
            builder: (context, state) {
              if (state.selectedNode != null) {
                return Column(
                  children: [
                    const Divider(color: Colors.white12),
                    PropertiesPanel(
                      key: ValueKey(state.selectedNode!.id),
                      node: state.selectedNode!,
                      onChanged: controller.updateNodeData,
                      onDelete: () =>
                          controller.deleteNode(state.selectedNode!.id),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
