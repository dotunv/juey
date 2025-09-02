class Tag {
  final String id;
  final String name;
  final String color; // Hex color code
  final String userId;

  Tag({
    required this.id,
    required this.name,
    required this.color,
    required this.userId,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String,
      userId: json['user_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'user_id': userId,
    };
  }

  Tag copyWith({
    String? id,
    String? name,
    String? color,
    String? userId,
  }) {
    return Tag(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      userId: userId ?? this.userId,
    );
  }
}
