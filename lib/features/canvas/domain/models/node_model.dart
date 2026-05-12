import 'package:flutter/material.dart';
import 'package:software_engineering_project/features/canvas/domain/models/node_type.dart';

class NodeModel {
  NodeModel({
    required this.id,
    required this.type,
    required this.position,
    this.logText = 'Hello World',
    this.colorValue = Colors.white,
    this.delayMs = 1000,
    this.name = '',
    this.age = '',
    this.address = '',
    this.date = '',
    this.email = '',
    this.triggerName = 'ON START',
  });

  factory NodeModel.fromJson(Map<String, dynamic> json) {
    return NodeModel(
      id: json['id'] as String,
      type: NodeType.values.firstWhere((e) => e.name == json['type']),
      position: Offset(
        (json['x'] as num).toDouble(),
        (json['y'] as num).toDouble(),
      ),
      logText: json['logText'] as String? ?? '',
      colorValue: Color(json['colorValue'] as int? ?? 0xFFFFFFFF),
      delayMs: json['delayMs'] as int? ?? 1000,
      name: json['name'] as String? ?? '',
      age: json['age'] as String? ?? '',
      address: json['address'] as String? ?? '',
      date: json['date'] as String? ?? '',
      email: json['email'] as String? ?? '',
      triggerName: json['triggerName'] as String? ?? 'ON START',
    );
  }
  final String id;
  final NodeType type;
  Offset position;
  String logText;
  Color colorValue;
  int delayMs;
  String name;
  String age;
  String address;
  String date;
  String email;
  String triggerName;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'x': position.dx,
    'y': position.dy,
    'logText': logText,
    'colorValue': colorValue.value,
    'delayMs': delayMs,
    'name': name,
    'age': age,
    'address': address,
    'date': date,
    'email': email,
    'triggerName': triggerName,
  };
}
