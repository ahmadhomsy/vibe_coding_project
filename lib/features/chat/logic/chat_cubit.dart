import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:software_engineering_project/features/canvas/domain/models/node_type.dart';
import 'package:software_engineering_project/features/canvas/logic/automation_cubit.dart';

class ChatMessage {
  ChatMessage({required this.text, required this.isUser});
  final String text;
  final bool isUser;
}

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? apiKey;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.apiKey,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? apiKey,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      apiKey: apiKey ?? this.apiKey,
    );
  }
}

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({required this.automationCubit}) : super(const ChatState());

  final AutomationCubit automationCubit;

  List<ChatMessage> get messages => state.messages;
  bool get isLoading => state.isLoading;
  String? get apiKey => state.apiKey;

  void setApiKey(String key) {
    emit(state.copyWith(apiKey: key));
  }

  Future<void> sendMessage(String text) async {
    if (state.apiKey == null || state.apiKey!.isEmpty) {
      final defaultMsg = ChatMessage(
        text: 'Please provide an API Key first.',
        isUser: false,
      );
      emit(state.copyWith(messages: List.of(state.messages)..add(defaultMsg)));
      return;
    }

    emit(
      state.copyWith(
        messages: List.of(state.messages)
          ..add(ChatMessage(text: text, isUser: true)),
        isLoading: true,
      ),
    );

    try {
      final model = GenerativeModel(
        model: 'gemini-3-flash-preview',
        apiKey: state.apiKey!,
      );

      final systemPrompt =
          """
You are an AI assistant for a node-based automation tool.
You can converse normally, but you also have the power to create and run automations.

Available Node Types: ${NodeType.values.map((e) => e.name).join(', ')}

When the user asks to create an automation, return a JSON object with this structure:
{
  "type": "automation",
  "nodes": [
    {"id": "1", "type": "trigger", "x": 100, "y": 100, "triggerName": "START"},
    {"id": "2", "type": "log", "x": 300, "y": 100, "logText": "Hello from AI"}
  ],
  "connections": [
    {"from": "1", "to": "2"}
  ],
  "run": true/false
}

If the user just wants to chat, return:
{
  "type": "chat",
  "text": "Your friendly response here"
}

IMPORTANT: Do NOT use literal newlines inside JSON strings. Use \\n instead.
Be helpful and creative!
""";

      final content = [Content.text(systemPrompt), Content.text(text)];
      final response = await model.generateContent(content);

      if (response.text != null) {
        final rawText = response.text!;
        Map<String, dynamic>? data;

        try {
          // Try to extract JSON from markdown blocks or raw text
          final jsonMatch = RegExp(
            r'\{.*\}',
            dotAll: true,
          ).stringMatch(rawText);
          if (jsonMatch != null) {
            data = jsonDecode(jsonMatch) as Map<String, dynamic>?;
          }
        } catch (e) {
          // ignore: avoid_print
          print('JSON Parsing error: $e');
        }

        final nextMessages = List<ChatMessage>.of(state.messages);

        if (data != null && data['type'] == 'automation') {
          _handleAutomationCommand(data);
          nextMessages.add(
            ChatMessage(text: 'Automation created!', isUser: false),
          );
        } else if (data != null && data['type'] == 'chat') {
          nextMessages.add(
            ChatMessage(
              text: data['text']?.toString() ?? rawText,
              isUser: false,
            ),
          );
        } else {
          // If JSON parsing completely failed, try to extract "text" using regex
          final textMatch = RegExp(
            r'"text"\s*:\s*"(.*?)"',
            dotAll: true,
          ).firstMatch(rawText);
          if (textMatch != null) {
            nextMessages.add(
              ChatMessage(text: textMatch.group(1) ?? rawText, isUser: false),
            );
          } else {
            final displayMsg = rawText
                .replaceAll(RegExp(r'\{.*\}', dotAll: true), '')
                .trim();
            nextMessages.add(
              ChatMessage(
                text: displayMsg.isEmpty ? rawText : displayMsg,
                isUser: false,
              ),
            );
          }
        }

        emit(state.copyWith(messages: nextMessages, isLoading: false));
        return;
      }
    } catch (e) {
      final nextMessages = List<ChatMessage>.of(state.messages);
      nextMessages.add(ChatMessage(text: 'Error: $e', isUser: false));
      emit(state.copyWith(messages: nextMessages, isLoading: false));
      return;
    }

    emit(state.copyWith(isLoading: false));
  }

  void _handleAutomationCommand(Map<String, dynamic> data) {
    final nodes = data['nodes'] as List;
    final connections = data['connections'] as List;

    // Convert keys to match NodeModel.fromJson
    final formattedNodes = nodes.map((n) {
      return {
        'id':
            n['id']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        'type': n['type']?.toString() ?? 'log',
        'x': (n['x'] as num?)?.toDouble() ?? 100.0,
        'y': (n['y'] as num?)?.toDouble() ?? 100.0,
        'logText': n['logText']?.toString() ?? '',
        'delayMs': (n['delayMs'] as num?)?.toInt() ?? 1000,
        'name': n['name']?.toString() ?? '',
        'age': n['age']?.toString() ?? '',
        'address': n['address']?.toString() ?? '',
        'date': n['date']?.toString() ?? '',
        'email': n['email']?.toString() ?? '',
        'triggerName': n['triggerName']?.toString() ?? 'START',
      };
    }).toList();

    final formattedConnections = connections.map((c) {
      return {
        'from': c['from']?.toString() ?? '',
        'to': c['to']?.toString() ?? '',
      };
    }).toList();

    automationCubit.clearAndBuild(formattedNodes, formattedConnections);

    if (data['run'] == true) {
      automationCubit.runAutomation();
    }
  }

  void clearChat() {
    emit(state.copyWith(messages: []));
  }
}
