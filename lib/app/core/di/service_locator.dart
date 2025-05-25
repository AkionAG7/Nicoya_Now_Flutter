import 'package:get_it/get_it.dart';
import 'package:nicoya_now/app/core/services/role_service.dart';
import 'package:nicoya_now/app/features/auth/data/datasources/auth_data_source.dart';
import 'package:nicoya_now/app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:nicoya_now/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:nicoya_now/app/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:nicoya_now/app/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:nicoya_now/app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:nicoya_now/app/features/merchant/data/datasources/merchant_data_source.dart';
import 'package:nicoya_now/app/features/merchant/data/repositories/merchant_repository_impl.dart';
import 'package:nicoya_now/app/features/merchant/domain/repositories/merchant_repository.dart';
import 'package:nicoya_now/app/features/merchant/domain/usecases/register_merchant_usecase.dart';
import 'package:nicoya_now/app/features/merchant/presentation/controllers/merchant_registration_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final GetIt locator = GetIt.instance;

void setupServiceLocator() {
  // External dependencies
  if (!locator.isRegistered<SupabaseClient>()) {
    final supabase = Supabase.instance.client;
    locator.registerSingleton<SupabaseClient>(supabase);
  }

  locator.registerLazySingleton<RoleService>(
    () => RoleService(locator<SupabaseClient>()),
  );  
  
  // Data sources
  locator.registerLazySingleton<AuthDataSource>(
    () => SupabaseAuthDataSource(locator<SupabaseClient>()),
  );
  locator.registerLazySingleton<MerchantDataSource>(
    () => SupabaseMerchantDataSource(locator<SupabaseClient>()),
  );

  // Repositories
  locator.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(locator<AuthDataSource>()),
  );
  locator.registerLazySingleton<MerchantRepository>(
    () => MerchantRepositoryImpl(locator<MerchantDataSource>()),
  );

  // Use cases
  locator.registerLazySingleton<SignInUseCase>(
    () => SignInUseCase(locator<AuthRepository>()),
  );
  locator.registerLazySingleton<SignUpUseCase>(
    () => SignUpUseCase(locator<AuthRepository>()),
  );
  locator.registerLazySingleton<RegisterMerchantUseCase>(
    () => RegisterMerchantUseCase(locator<MerchantRepository>()),
  );

  locator.registerFactory<AuthController>(() => AuthController(
        signInUseCase : locator<SignInUseCase>(),
        signUpUseCase : locator<SignUpUseCase>(),
        roleService   : locator<RoleService>(),  
      ));

  locator.registerFactory<MerchantRegistrationController>(
    () => MerchantRegistrationController(
      registerMerchantUseCase: locator<RegisterMerchantUseCase>(),
    ),
  );
}