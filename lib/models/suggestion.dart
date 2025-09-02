class Suggestion {
  final String id;
  final String taskId; // Reference to the task being suggested
  final double confidence; // 0.0 to 1.0, how confident the suggestion is
  final DateTime suggestedAt;
  final String userId;
  final bool? accepted; // User feedback: true for accept, false for reject, null for pending

  Suggestion({
    required this.id,
    required this.taskId,
    required this.confidence,
    required this.suggestedAt,
    required this.userId,
    this.accepted,
  });

  factory Suggestion.fromJson(Map<String, dynamic> json) {
    return Suggestion(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      suggestedAt: DateTime.parse(json['suggested_at']),
      userId: json['user_id'] as String,
      accepted: json['accepted'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task_id': taskId,
      'confidence': confidence,
      'suggested_at': suggestedAt.toIso8601String(),
      'user_id': userId,
      'accepted': accepted,
    };
  }

  Suggestion copyWith({
    String? id,
    String? taskId,
    double? confidence,
    DateTime? suggestedAt,
    String? userId,
    bool? accepted,
  }) {
    return Suggestion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      confidence: confidence ?? this.confidence,
      suggestedAt: suggestedAt ?? this.suggestedAt,
      userId: userId ?? this.userId,
      accepted: accepted ?? this.accepted,
    );
  }
}
