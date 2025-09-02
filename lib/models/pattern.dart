class Pattern {
  final String id;
  final String taskId; // Reference to the task for this pattern
  final String frequency; // e.g., 'daily', 'weekly', 'monthly'
  final DateTime lastDone;
  final int totalCount; // Total times this task was done
  final String userId;

  Pattern({
    required this.id,
    required this.taskId,
    required this.frequency,
    required this.lastDone,
    required this.totalCount,
    required this.userId,
  });

  factory Pattern.fromJson(Map<String, dynamic> json) {
    return Pattern(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      frequency: json['frequency'] as String,
      lastDone: DateTime.parse(json['last_done']),
      totalCount: json['total_count'] as int,
      userId: json['user_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task_id': taskId,
      'frequency': frequency,
      'last_done': lastDone.toIso8601String(),
      'total_count': totalCount,
      'user_id': userId,
    };
  }

  Pattern copyWith({
    String? id,
    String? taskId,
    String? frequency,
    DateTime? lastDone,
    int? totalCount,
    String? userId,
  }) {
    return Pattern(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      frequency: frequency ?? this.frequency,
      lastDone: lastDone ?? this.lastDone,
      totalCount: totalCount ?? this.totalCount,
      userId: userId ?? this.userId,
    );
  }
}
