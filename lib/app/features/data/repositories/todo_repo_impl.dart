

import 'package:nicoya_now/app/data/datasources/todo_remote_ds.dart';
import 'package:nicoya_now/app/features/domain/entities/todo.dart';
import 'package:nicoya_now/app/features/domain/repositories/todo_repository.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoRemoteDs remoteDs;


  TodoRepositoryImpl(this.remoteDs);

  @override
  Future<List<Todo>> getTodos() async {
    final models = await remoteDs.getTodos();
    return models.map((m) => m.toEntity()).toList();
  }
}
