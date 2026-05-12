class Connection {
  Connection({required this.fromNodeId, required this.toNodeId});

  factory Connection.fromJson(Map<String, dynamic> json) => Connection(
    fromNodeId: json['from'] as String,
    toNodeId: json['to'] as String,
  );
  final String fromNodeId;
  final String toNodeId;

  Map<String, dynamic> toJson() => {
    'from': fromNodeId,
    'to': toNodeId,
  };
}
