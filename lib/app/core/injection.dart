import 'package:get_it/get_it.dart';
import 'package:nicoya_now/app/data/datasources/todo_remote_ds.dart';
import 'package:nicoya_now/app/features/data/repositories/todo_repo_impl.dart';
import 'package:nicoya_now/app/features/domain/Usecases/get_todos.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


final getIt = GetIt.instance;

Future<void> initInjection() async {
  // ============ EXTERNOS ============
  final supabase = Supabase.instance.client;
  getIt.registerSingleton<SupabaseClient>(supabase);

  // ============ DATA SOURCES ============
  getIt.registerLazySingleton<TodoRemoteDs>(() => TodoRemoteDs(getIt()));

  // ============ REPOS ============
  getIt.registerLazySingleton<TodoRepositoryImpl>(
      () => TodoRepositoryImpl(getIt()));

  // ============ USECASES ============
  getIt.registerLazySingleton<GetTodos>(() => GetTodos(getIt()));
}
