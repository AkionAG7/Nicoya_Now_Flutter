
import 'package:nicoya_now/app/features/domain/repositories/todo_repository.dart';


import '../entities/todo.dart';


class GetTodos {
  final TodoRepository repository;
  GetTodos(this.repository);

  Future<List<Todo>> call() => repository.getTodos();
}
