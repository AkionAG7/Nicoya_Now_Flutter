

import 'package:nicoya_now/app/features/domain/entities/todo.dart';

abstract class TodoRepository {
  Future<List<Todo>> getTodos();
}
