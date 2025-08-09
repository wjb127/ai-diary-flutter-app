class DiaryEntry {
  final String id;
  final String userId;
  final DateTime date;
  final String title;
  final String originalContent;
  final String? generatedContent;
  final DateTime createdAt;
  final DateTime updatedAt;

  DiaryEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.title,
    required this.originalContent,
    this.generatedContent,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DiaryEntry.fromJson(Map<String, dynamic> json) {
    return DiaryEntry(
      id: json['id'],
      userId: json['user_id'],
      date: DateTime.parse(json['date']),
      title: json['title'],
      originalContent: json['original_content'],
      generatedContent: json['generated_content'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0],
      'title': title,
      'original_content': originalContent,
      'generated_content': generatedContent,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  DiaryEntry copyWith({
    String? id,
    String? userId,
    DateTime? date,
    String? title,
    String? originalContent,
    String? generatedContent,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      title: title ?? this.title,
      originalContent: originalContent ?? this.originalContent,
      generatedContent: generatedContent ?? this.generatedContent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}