

import 'package:nicoya_now/app/features/domain/entities/todo.dart';

class TodoModel {
  final String id;
  final String title;
  final bool completed;

  const TodoModel({
    required this.id,
    required this.title,
    required this.completed,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) => TodoModel(
        id: json['id'] as String,
        title: json['title'] as String,
        completed: json['completed'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'completed': completed,
      };

  Todo toEntity() => Todo(
        id: id,
        title: title,
        completed: completed,
      );
}
