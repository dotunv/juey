class Task {
  final String id;
  final String title;
  final String? description;
  final List<String> tagIds;
  final DateTime createdAt;
  final DateTime? completedAt;
  final bool isCompleted;
  final String userId; // For Supabase user association

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.tagIds,
    required this.createdAt,
    this.completedAt,
    required this.isCompleted,
    required this.userId,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      tagIds: List<String>.from(json['tag_ids'] ?? []),
      createdAt: DateTime.parse(json['created_at']),
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      isCompleted: json['is_completed'] as bool,
      userId: json['user_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'tag_ids': tagIds,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'is_completed': isCompleted,
      'user_id': userId,
    };
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? tagIds,
    DateTime? createdAt,
    DateTime? completedAt,
    bool? isCompleted,
    String? userId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      tagIds: tagIds ?? this.tagIds,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      userId: userId ?? this.userId,
    );
  }
}
