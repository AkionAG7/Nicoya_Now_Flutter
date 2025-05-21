import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


final getIt = GetIt.instance;

Future<void> initInjection() async {
  // ============ EXTERNOS ============
  final supabase = Supabase.instance.client;
  getIt.registerSingleton<SupabaseClient>(supabase);

}
