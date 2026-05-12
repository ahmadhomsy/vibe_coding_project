import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:software_engineering_project/features/canvas/presentation/bloc/canvas_ui_cubit.dart';
import 'package:software_engineering_project/features/chat/logic/chat_cubit.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class AIChatPanel extends StatefulWidget {
  const AIChatPanel({super.key});

  @override
  State<AIChatPanel> createState() => _AIChatPanelState();
}

class _AIChatPanelState extends State<AIChatPanel> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _apiController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatCubit, ChatState>(
      listenWhen: (previous, current) =>
          previous.messages.length != current.messages.length,
      listener: (context, state) => _scrollToBottom(),
      builder: (BuildContext context, ChatState state) {
        final chatCubit = context.read<ChatCubit>();
        final screenWidth = MediaQuery.of(context).size.width;
        final panelWidth = (screenWidth < 900 ? screenWidth * 0.4 : 400.0)
            .clamp(280.0, 400.0);

        return Container(
          width: panelWidth,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              left: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
          ),
          child: Column(
            children: [
              _buildHeader(context, chatCubit),
              if (state.apiKey == null || state.apiKey!.isEmpty)
                _buildApiKeyInput(chatCubit),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final msg = state.messages[index];
                    return _buildChatBubble(msg, panelWidth * 0.8);
                  },
                ),
              ),
              if (state.isLoading)
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    color: Color(0xFF6366F1),
                  ),
                ),
              _buildInputArea(chatCubit),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, ChatCubit chatCubit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.black12,
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Color(0xFF6366F1)),
          const SizedBox(width: 12),
          const Text(
            'GEMINI AI',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: chatCubit.clearChat,
            icon: const Icon(
              Icons.delete_sweep,
              size: 20,
              color: Colors.white30,
            ),
            tooltip: 'Clear Chat',
          ),
          IconButton(
            onPressed: context.read<CanvasUiCubit>().toggleChat,
            icon: const Icon(
              Icons.close,
              size: 20,
              color: Colors.white70,
            ),
            tooltip: 'Close AI',
          ),
        ],
      ),
    );
  }

  Widget _buildApiKeyInput(ChatCubit chatCubit) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orangeAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gemini API Key Required',
            style: TextStyle(
              color: Colors.orangeAccent,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _apiController,
            obscureText: true,
            style: const TextStyle(fontSize: 12),
            decoration: InputDecoration(
              hintText: 'Paste your key here...',
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.check_circle,
                  color: Colors.orangeAccent,
                ),
                onPressed: () => chatCubit.setApiKey(_apiController.text),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage msg, double maxWidth) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: maxWidth,
        ),
        decoration: BoxDecoration(
          color: msg.isUser ? const Color(0xFF6366F1) : const Color(0xFF0F172A),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.isUser ? 16 : 0),
            bottomRight: Radius.circular(msg.isUser ? 0 : 16),
          ),
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            color: msg.isUser ? Colors.white : Colors.white70,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(ChatCubit chatCubit) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black26,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              onSubmitted: (_) => _handleSend(chatCubit),
              decoration: const InputDecoration(
                hintText: 'Ask AI to build something...',
                hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          IconButton(
            onPressed: _listenToSpeech,
            icon: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: _isListening ? Colors.redAccent : const Color(0xFF6366F1),
            ),
          ),
          IconButton(
            onPressed: () => _handleSend(chatCubit),
            icon: const Icon(Icons.send, color: Color(0xFF6366F1)),
          ),
        ],
      ),
    );
  }

  void _listenToSpeech() async {
    if (!_isListening) {
      bool available = false;
      try {
        available = await _speech.initialize(
          onError: (val) => print('Speech Error: $val'),
          onStatus: (val) {
            print('Speech Status: $val');
            if (val == 'done' || val == 'notListening') {
              if (mounted) setState(() => _isListening = false);
            }
          },
        );
      } catch (e) {
        print('Speech initialization failed: $e');
      }

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          localeId: 'ar-SA',
          onResult: (val) {
            setState(() {
              _textController.text = val.recognizedWords;
            });
          },
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Speech recognition not available on this platform or permission denied',
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  void _handleSend(ChatCubit chatCubit) {
    if (_textController.text.trim().isEmpty) return;
    final text = _textController.text;
    _textController.clear();
    chatCubit.sendMessage(text);
  }
}
