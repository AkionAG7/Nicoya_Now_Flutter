import 'package:get_it/get_it.dart';
import 'package:nicoya_now/app/features/auth/data/datasources/auth_data_source.dart';
import 'package:nicoya_now/app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:nicoya_now/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:nicoya_now/app/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:nicoya_now/app/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:nicoya_now/app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final GetIt locator = GetIt.instance;

void setupServiceLocator() {
  // External dependencies
  if (!locator.isRegistered<SupabaseClient>()) {
    final supabase = Supabase.instance.client;
    locator.registerSingleton<SupabaseClient>(supabase);
  }

  // Data sources
  locator.registerLazySingleton<AuthDataSource>(
    () => SupabaseAuthDataSource(locator<SupabaseClient>()),
  );

  // Repositories
  locator.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(locator<AuthDataSource>()),
  );

  // Use cases
  locator.registerLazySingleton<SignInUseCase>(
    () => SignInUseCase(locator<AuthRepository>()),
  );
  locator.registerLazySingleton<SignUpUseCase>(
    () => SignUpUseCase(locator<AuthRepository>()),
  );

  // Controllers
  locator.registerFactory<AuthController>(
    () => AuthController(
      signInUseCase: locator<SignInUseCase>(),
      signUpUseCase: locator<SignUpUseCase>(),
    ),
  );
}
