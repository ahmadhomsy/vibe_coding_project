import 'package:flutter/material.dart';

class LogEntry {
  LogEntry({
    required this.message,
    required this.color,
    required this.timestamp,
  });
  final String message;
  final Color color;
  final DateTime timestamp;
}
