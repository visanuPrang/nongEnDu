//โครงสร้าง database

class Todo {
  int id;
  String title;
  String createdAt;
  String? updatedAt;

  Todo(
      {required this.id,
      required this.title,
      required this.createdAt,
      this.updatedAt});

  factory Todo.fromSqfliteDatabase(Map<String, dynamic> map) => Todo(
        id: map['id']?.toInt() ?? 0,
        title: map['title'] ?? '',
        createdAt:
            DateTime.fromMicrosecondsSinceEpoch(map['created_at']).toString(),
        updatedAt: map['updated_at'] == null
            ? null
            : DateTime.fromMicrosecondsSinceEpoch(map['updated_at'])
                .toIso8601String(),
      );
}
