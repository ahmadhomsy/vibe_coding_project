import 'package:flutter/material.dart';
import 'package:software_engineering_project/features/canvas/domain/models/node_model.dart';
import 'package:software_engineering_project/features/canvas/domain/models/node_type.dart';

class PropertiesPanel extends StatefulWidget {
  const PropertiesPanel({
    required this.node,
    required this.onChanged,
    required this.onDelete,
    super.key,
  });
  final NodeModel node;
  final VoidCallback onChanged;
  final VoidCallback onDelete;

  @override
  State<PropertiesPanel> createState() => _PropertiesPanelState();
}

class _PropertiesPanelState extends State<PropertiesPanel> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _getCurrentText());
  }

  String _getCurrentText() {
    switch (widget.node.type) {
      case NodeType.log:
        return widget.node.logText;
      case NodeType.name:
        return widget.node.name;
      case NodeType.age:
        return widget.node.age;
      case NodeType.address:
        return widget.node.address;
      case NodeType.date:
        return widget.node.date;
      case NodeType.email:
        return widget.node.email;
      default:
        return '';
    }
  }

  void _updateCurrentText(String val) {
    switch (widget.node.type) {
      case NodeType.log:
        widget.node.logText = val;
      case NodeType.name:
        widget.node.name = val;
      case NodeType.age:
        widget.node.age = val;
      case NodeType.address:
        widget.node.address = val;
      case NodeType.date:
        widget.node.date = val;
      case NodeType.email:
        widget.node.email = val;
      default:
        break;
    }
  }

  @override
  void didUpdateWidget(PropertiesPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.node.id != widget.node.id) {
      _controller.text = _getCurrentText();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PROPERTIES: ${widget.node.type.name.toUpperCase()}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 16),
          if (widget.node.type == NodeType.log ||
              widget.node.type == NodeType.name ||
              widget.node.type == NodeType.age ||
              widget.node.type == NodeType.address ||
              widget.node.type == NodeType.date ||
              widget.node.type == NodeType.email)
            TextField(
              decoration: InputDecoration(
                labelText: widget.node.type.name.toUpperCase(),
                border: const OutlineInputBorder(),
              ),
              onChanged: (val) {
                _updateCurrentText(val);
                widget.onChanged();
              },
              controller: _controller,
            ),
          if (widget.node.type == NodeType.color)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  [
                        Colors.white,
                        Colors.red,
                        Colors.green,
                        Colors.blue,
                        Colors.yellow,
                        Colors.purple,
                        Colors.orange,
                      ]
                      .map(
                        (c) => GestureDetector(
                          onTap: () {
                            widget.node.colorValue = c;
                            widget.onChanged();
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: c,
                              border: Border.all(
                                color: widget.node.colorValue == c
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          if (widget.node.type == NodeType.delay)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Delay: ${widget.node.delayMs}ms',
                  style: const TextStyle(fontSize: 12),
                ),
                Slider(
                  value: widget.node.delayMs.toDouble(),
                  min: 100,
                  max: 5000,
                  divisions: 49,
                  onChanged: (val) {
                    widget.node.delayMs = val.toInt();
                    widget.onChanged();
                  },
                ),
              ],
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: widget.onDelete,
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('DELETE NODE'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
