import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_engineering_project/core/theme/app_colors.dart';
import 'package:software_engineering_project/features/canvas/logic/automation_cubit.dart';
import 'package:software_engineering_project/features/canvas/presentation/bloc/canvas_ui_cubit.dart';
import 'package:software_engineering_project/features/canvas/presentation/widgets/canvas_area.dart';
import 'package:software_engineering_project/features/canvas/presentation/widgets/canvas_sidebar.dart';
import 'package:software_engineering_project/features/canvas/presentation/widgets/console_panel.dart';
import 'package:software_engineering_project/features/chat/logic/chat_cubit.dart';
import 'package:software_engineering_project/features/chat/presentation/widgets/ai_chat_panel.dart';

class MainCanvasPage extends StatelessWidget {
  const MainCanvasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AutomationCubit()),
      ],
      child: Builder(
        builder: (context) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (ctx) => ChatCubit(
                  automationCubit: ctx.read<AutomationCubit>(),
                ),
              ),
              BlocProvider(create: (_) => CanvasUiCubit()),
            ],
            child: const _MainCanvasView(),
          );
        },
      ),
    );
  }
}

class _MainCanvasView extends StatelessWidget {
  const _MainCanvasView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CanvasUiCubit, CanvasUiState>(
      builder: (context, uiState) {
        return BlocBuilder<AutomationCubit, AutomationState>(
          builder: (context, automationState) {
            final uiCubit = context.read<CanvasUiCubit>();
            final controller = context.read<AutomationCubit>();

            return Scaffold(
              body: Stack(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              flex: 3,
                              child: CanvasAreaWidget(controller: controller),
                            ),
                            Expanded(
                              child: ConsolePanel(logs: automationState.logs),
                            ),
                          ],
                        ),
                      ),
                      if (uiState.showChat) const AIChatPanel(),
                    ],
                  ),
                  if (uiState.isSidebarOpen)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: CanvasSidebar(
                        controller: controller,
                        uiCubit: uiCubit,
                      ),
                    ),
                  if (!uiState.isSidebarOpen)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.text.withValues(alpha: 0.1),
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () => uiCubit.setSidebarOpen(true),
                          tooltip: 'Open Sidebar',
                        ),
                      ),
                    ),
                ],
              ),
              floatingActionButton: uiState.showChat
                  ? null
                  : FloatingActionButton(
                      onPressed: uiCubit.toggleChat,
                      backgroundColor: AppColors.primary,
                      child: const Icon(Icons.auto_awesome),
                    ),
            );
          },
        );
      },
    );
  }
}
