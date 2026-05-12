import 'package:flutter/material.dart';
import 'package:software_engineering_project/core/theme/app_theme.dart';
import 'package:software_engineering_project/features/canvas/presentation/pages/main_canvas_page.dart';

void main() {
  runApp(const NodeAutomationApp());
}

class NodeAutomationApp extends StatelessWidget {
  const NodeAutomationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Node-Based Automation',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainCanvasPage(),
    );
  }
}
