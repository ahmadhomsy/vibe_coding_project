import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_engineering_project/features/canvas/domain/models/connection.dart';
import 'package:software_engineering_project/features/canvas/domain/models/log_entry.dart';
import 'package:software_engineering_project/features/canvas/domain/models/node_model.dart';
import 'package:software_engineering_project/features/canvas/domain/models/node_type.dart';

class AutomationState {
  final List<NodeModel> nodes;
  final List<Connection> connections;
  final List<LogEntry> logs;
  final NodeModel? selectedNode;
  final bool isRunning;
  final String? selectedPortNodeId;

  const AutomationState({
    this.nodes = const [],
    this.connections = const [],
    this.logs = const [],
    this.selectedNode,
    this.isRunning = false,
    this.selectedPortNodeId,
  });

  AutomationState copyWith({
    List<NodeModel>? nodes,
    List<Connection>? connections,
    List<LogEntry>? logs,
    NodeModel? selectedNode,
    bool? isRunning,
    String? selectedPortNodeId,
    bool clearSelectedNode = false,
    bool clearSelectedPortNodeId = false,
  }) {
    return AutomationState(
      nodes: nodes ?? this.nodes,
      connections: connections ?? this.connections,
      logs: logs ?? this.logs,
      selectedNode: clearSelectedNode
          ? null
          : (selectedNode ?? this.selectedNode),
      isRunning: isRunning ?? this.isRunning,
      selectedPortNodeId: clearSelectedPortNodeId
          ? null
          : (selectedPortNodeId ?? this.selectedPortNodeId),
    );
  }
}

class AutomationCubit extends Cubit<AutomationState> {
  AutomationCubit() : super(const AutomationState());

  List<NodeModel> get nodes => state.nodes;
  List<Connection> get connections => state.connections;
  List<LogEntry> get logs => state.logs;
  NodeModel? get selectedNode => state.selectedNode;
  bool get isRunning => state.isRunning;
  String? get selectedPortNodeId => state.selectedPortNodeId;

  void addNode(NodeType type, [Offset? position]) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final newNode = NodeModel(
      id: id,
      type: type,
      position: position ?? const Offset(100, 100),
    );
    emit(state.copyWith(nodes: List.of(state.nodes)..add(newNode)));
  }

  void selectNode(NodeModel? node) {
    emit(state.copyWith(selectedNode: node, clearSelectedNode: node == null));
  }

  void deleteNode(String id) {
    var nodes = List<NodeModel>.of(state.nodes)..removeWhere((n) => n.id == id);
    var conns = List<Connection>.of(state.connections)
      ..removeWhere((c) => c.fromNodeId == id || c.toNodeId == id);

    emit(
      state.copyWith(
        nodes: nodes,
        connections: conns,
        clearSelectedNode: state.selectedNode?.id == id,
      ),
    );
  }

  void handlePortClick(String nodeId, bool isOutput) {
    if (isOutput) {
      emit(state.copyWith(selectedPortNodeId: nodeId));
    } else {
      if (state.selectedPortNodeId != null &&
          state.selectedPortNodeId != nodeId) {
        final exists = state.connections.any(
          (c) =>
              c.fromNodeId == state.selectedPortNodeId && c.toNodeId == nodeId,
        );
        if (!exists) {
          final newConns = List<Connection>.of(state.connections);
          newConns.add(
            Connection(fromNodeId: state.selectedPortNodeId!, toNodeId: nodeId),
          );
          emit(
            state.copyWith(
              connections: newConns,
              clearSelectedPortNodeId: true,
            ),
          );
        } else {
          emit(state.copyWith(clearSelectedPortNodeId: true));
        }
      }
    }
  }

  void updateNodePosition(NodeModel node, Offset newPos) {
    node.position = newPos;
    emit(state.copyWith(nodes: List.of(state.nodes)));
  }

  void updateNodeData() {
    emit(state.copyWith(nodes: List.of(state.nodes)));
  }

  Future<void> runAutomation() async {
    if (state.isRunning) return;

    emit(state.copyWith(isRunning: true, logs: []));
    _addLog('Starting execution...', Colors.blueAccent);

    var currentColor = Colors.white;
    final visited = <String>[];
    var startNodes = state.nodes
        .where((node) => node.type == NodeType.trigger)
        .toList();
    if (startNodes.isEmpty) {
      startNodes = state.nodes
          .where((node) => !state.connections.any((c) => c.toNodeId == node.id))
          .toList();
    }

    for (final startNode in startNodes) {
      await _executeNode(startNode, currentColor, visited);
    }

    _addLog('Execution finished.', Colors.blueAccent);
    emit(state.copyWith(isRunning: false));
  }

  Future<void> _executeNode(
    NodeModel node,
    Color currentColor,
    List<String> visited,
  ) async {
    if (visited.contains(node.id)) return;
    visited.add(node.id);

    var nextColor = currentColor;
    if (node.type == NodeType.color) {
      nextColor = node.colorValue;
    } else if (node.type == NodeType.log) {
      _addLog(node.logText, currentColor);
    } else if (node.type == NodeType.delay) {
      _addLog('Waiting ${node.delayMs}ms...', Colors.white24);
      await Future.delayed(Duration(milliseconds: node.delayMs));
    } else if (node.type == NodeType.name) {
      _addLog('Name: ${node.name}', currentColor);
    } else if (node.type == NodeType.age) {
      _addLog('Age: ${node.age}', currentColor);
    } else if (node.type == NodeType.address) {
      _addLog('Address: ${node.address}', currentColor);
    } else if (node.type == NodeType.date) {
      _addLog('Date: ${node.date}', currentColor);
    } else if (node.type == NodeType.email) {
      _addLog('Email: ${node.email}', currentColor);
    } else if (node.type == NodeType.trigger) {
      _addLog('Triggered: ${node.triggerName}', Colors.greenAccent);
    }

    final nextConnections = state.connections.where(
      (c) => c.fromNodeId == node.id,
    );
    for (final conn in nextConnections) {
      final nextNode = state.nodes.firstWhere((n) => n.id == conn.toNodeId);
      await _executeNode(nextNode, nextColor, visited);
    }
  }

  void _addLog(String message, Color color) {
    final entry = LogEntry(
      message: message,
      color: color,
      timestamp: DateTime.now(),
    );
    emit(state.copyWith(logs: List.of(state.logs)..add(entry)));
  }

  void clearCanvas() {
    emit(const AutomationState());
  }

  String saveProject() {
    final data = {
      'nodes': state.nodes.map((n) => n.toJson()).toList(),
      'connections': state.connections.map((c) => c.toJson()).toList(),
    };
    return jsonEncode(data);
  }

  // AI Helper Methods
  String addNodeWithType(NodeType type, double x, double y) {
    final id =
        DateTime.now().millisecondsSinceEpoch.toString() +
        state.nodes.length.toString();
    final newNode = NodeModel(
      id: id,
      type: type,
      position: Offset(x, y),
    );
    emit(state.copyWith(nodes: List.of(state.nodes)..add(newNode)));
    return id;
  }

  void connectNodes(String fromId, String toId) {
    final exists = state.connections.any(
      (c) => c.fromNodeId == fromId && c.toNodeId == toId,
    );
    if (!exists) {
      final newConns = List<Connection>.of(state.connections);
      newConns.add(Connection(fromNodeId: fromId, toNodeId: toId));
      emit(state.copyWith(connections: newConns));
    }
  }

  void clearAndBuild(
    List<Map<String, dynamic>> nodesJson,
    List<Map<String, dynamic>> connectionsJson,
  ) {
    final newNodes = <NodeModel>[];
    final newConns = <Connection>[];

    for (final nodeJson in nodesJson) {
      newNodes.add(NodeModel.fromJson(nodeJson));
    }
    for (final connJson in connectionsJson) {
      newConns.add(Connection.fromJson(connJson));
    }
    emit(AutomationState(nodes: newNodes, connections: newConns));
  }
}
