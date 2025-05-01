import 'package:nicoya_now/app/features/data/models/todo_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class TodoRemoteDs {
  final SupabaseClient _client;
  TodoRemoteDs(this._client);

  Future<List<TodoModel>> getTodos() async {
    final res = await _client
        .from('todos')
        .select()
        .order('created_at', ascending: false);

    // PostgREST ya devuelve List<dynamic>
    return (res as List)
        .map((e) => TodoModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
