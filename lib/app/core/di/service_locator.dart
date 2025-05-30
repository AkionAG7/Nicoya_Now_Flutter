import 'package:get_it/get_it.dart';
import 'package:nicoya_now/app/core/services/role_service.dart';
import 'package:nicoya_now/app/features/auth/data/datasources/auth_data_source.dart';
import 'package:nicoya_now/app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:nicoya_now/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:nicoya_now/app/features/auth/domain/usecases/add_user_role_usecase.dart';
import 'package:nicoya_now/app/features/auth/domain/usecases/get_user_roles_usecase.dart';
import 'package:nicoya_now/app/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:nicoya_now/app/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:nicoya_now/app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:nicoya_now/app/features/merchant/data/datasources/merchant_data_source.dart';
import 'package:nicoya_now/app/features/merchant/data/repositories/merchant_repository_impl.dart';
import 'package:nicoya_now/app/features/merchant/domain/repositories/merchant_repository.dart';
import 'package:nicoya_now/app/features/merchant/domain/usecases/get_merchant_byowner_usecase.dart';
import 'package:nicoya_now/app/features/merchant/domain/usecases/register_merchant_usecase.dart';
import 'package:nicoya_now/app/features/merchant/presentation/controllers/merchant_registration_controller.dart';
import 'package:nicoya_now/app/features/merchant/presentation/controllers/merchant_settings_controller.dart';
import 'package:nicoya_now/app/features/products/data/datasources/products_data_source.dart';
import 'package:nicoya_now/app/features/products/data/repositories/products_repository_impl.dart';
import 'package:nicoya_now/app/features/products/domain/repositories/products_repository.dart';
import 'package:nicoya_now/app/features/products/domain/usecases/add_product_usecase.dart';
import 'package:nicoya_now/app/features/products/domain/usecases/delete_product_usecase.dart';
import 'package:nicoya_now/app/features/products/domain/usecases/update_product_usecase.dart';
import 'package:nicoya_now/app/features/products/presentation/controllers/add_product_controller.dart';
import 'package:nicoya_now/app/features/products/presentation/controllers/update_product_controller.dart';
// Admin imports
import 'package:nicoya_now/app/core/network/network_info.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:nicoya_now/app/features/admin/data/datasources/merchant/merchant_remote_datasource.dart';
import 'package:nicoya_now/app/features/admin/data/repositories/merchant/merchant_repository_impl.dart';
import 'package:nicoya_now/app/features/admin/domain/repositories/merchant/merchant_repository.dart'
    as AdminMerchantRepo;
import 'package:nicoya_now/app/features/admin/domain/usecases/merchant/merchant_usecases.dart';
import 'package:nicoya_now/app/features/admin/presentation/controllers/admin_merchant_controller.dart';
// Driver admin imports
import 'package:nicoya_now/app/features/admin/data/datasources/driver/driver_remote_datasource.dart';
import 'package:nicoya_now/app/features/admin/data/repositories/driver/driver_repository_impl.dart';
import 'package:nicoya_now/app/features/admin/domain/repositories/driver/driver_repository.dart';
import 'package:nicoya_now/app/features/admin/domain/usecases/driver/driver_usecases.dart';
import 'package:nicoya_now/app/features/admin/presentation/controllers/admin_driver_controller.dart';
import 'package:nicoya_now/app/features/driver/presentation/controllers/driver_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final GetIt locator = GetIt.instance;

void setupServiceLocator() {
  // External dependencies
  if (!locator.isRegistered<SupabaseClient>()) {
    final supabase = Supabase.instance.client;
    locator.registerSingleton<SupabaseClient>(supabase);
  }

  locator.registerLazySingleton<RoleService>(
        () => RoleService(locator<SupabaseClient>()));

  // Data sources
  locator.registerLazySingleton<AuthDataSource>(
    () => SupabaseAuthDataSource(locator<SupabaseClient>()),
  );
  locator.registerLazySingleton<MerchantDataSource>(
    () => SupabaseMerchantDataSource(locator<SupabaseClient>()),
  );
locator.registerLazySingleton<ProductsDataSource>(
  () => ProductsDataSourceImpl(supabaseClient: locator<SupabaseClient>()),
);

  // Repositories
  locator.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(locator<AuthDataSource>()),
  );
  locator.registerLazySingleton<MerchantRepository>(
    () => MerchantRepositoryImpl(locator<MerchantDataSource>()),
  );
  locator.registerLazySingleton<ProductsRepository>(
  () => ProductsRepositoryImpl(dataSource: locator<ProductsDataSource>()),
);

  // Use cases
  locator.registerLazySingleton<SignInUseCase>(
    () => SignInUseCase(locator<AuthRepository>()),
  );  locator.registerLazySingleton<SignUpUseCase>(
    () => SignUpUseCase(locator<AuthRepository>()),
  );
  locator.registerLazySingleton<GetUserRolesUseCase>(
    () => GetUserRolesUseCase(locator<AuthRepository>()),
  );
  locator.registerLazySingleton<AddUserRoleUseCase>(
    () => AddUserRoleUseCase(locator<AuthRepository>()),
  );
  locator.registerLazySingleton<RegisterMerchantUseCase>(
    () => RegisterMerchantUseCase(locator<MerchantRepository>()),
  );
  locator.registerLazySingleton<GetMerchantByOwnerUseCase>(
    () => GetMerchantByOwnerUseCase(locator<MerchantRepository>()),
  );
  locator.registerLazySingleton<AddProductUseCase>(
    () => AddProductUseCase(locator<ProductsRepository>()),
  );
  locator.registerLazySingleton<UpdateProductUseCase>(
  () => UpdateProductUseCase(locator<ProductsRepository>()),
);
locator.registerLazySingleton<DeleteProductUseCase>(
  () => DeleteProductUseCase(locator<ProductsRepository>()),
);
  // Controllers
  locator.registerFactory<AuthController>(
    () => AuthController(
      signInUseCase: locator<SignInUseCase>(),
      signUpUseCase: locator<SignUpUseCase>(),
      roleService: locator<RoleService>(),
      getUserRolesUseCase: locator<GetUserRolesUseCase>(),
      addUserRoleUseCase: locator<AddUserRoleUseCase>(),
    ),
  );
  locator.registerFactory<MerchantRegistrationController>(
    () => MerchantRegistrationController(
      registerMerchantUseCase: locator<RegisterMerchantUseCase>(),
    ),
  );  locator.registerFactory<MerchantSettingsController>(
     () => MerchantSettingsController(locator<GetMerchantByOwnerUseCase>()),
   );
     // Admin dependencies
  // Registrar el ConnectionChecker
  locator.registerLazySingleton<InternetConnectionChecker>(
    () => InternetConnectionChecker.createInstance(),
  );

  locator.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectionChecker: locator<InternetConnectionChecker>()),
  );
    locator.registerLazySingleton<MerchantRemoteDataSource>(
    () => MerchantRemoteDataSourceImpl(supabase: locator<SupabaseClient>()),
  );
  
  locator.registerLazySingleton<AdminMerchantRepo.MerchantRepository>(
    () => AdminMerchantRepositoryImpl(
      remoteDataSource: locator<MerchantRemoteDataSource>(),
      networkInfo: locator<NetworkInfo>(),
    ),
  );
    locator.registerLazySingleton<GetAllMerchantsUseCase>(
    () => GetAllMerchantsUseCase(locator<AdminMerchantRepo.MerchantRepository>()),
  );
  
  locator.registerLazySingleton<ApproveMerchantUseCase>(
    () => ApproveMerchantUseCase(locator<AdminMerchantRepo.MerchantRepository>()),
  );
    locator.registerFactory<AdminMerchantController>(
    () => AdminMerchantController(
      getAllMerchantsUseCase: locator<GetAllMerchantsUseCase>(),
      approveMerchantUseCase: locator<ApproveMerchantUseCase>(),
    ),
  );

  // Driver admin dependencies
  locator.registerLazySingleton<DriverRemoteDataSource>(
    () => DriverRemoteDataSourceImpl(supabase: locator<SupabaseClient>()),
  );
  
  locator.registerLazySingleton<DriverRepository>(
    () => DriverRepositoryImpl(
      remoteDataSource: locator<DriverRemoteDataSource>(),
      networkInfo: locator<NetworkInfo>(),
    ),
  );
  
  locator.registerLazySingleton<GetAllDriversUseCase>(
    () => GetAllDriversUseCase(locator<DriverRepository>()),
  );
  
  locator.registerLazySingleton<ApproveDriverUseCase>(
    () => ApproveDriverUseCase(locator<DriverRepository>()),
  );
  
  locator.registerLazySingleton<RejectDriverUseCase>(
    () => RejectDriverUseCase(locator<DriverRepository>()),
  );
  
  locator.registerFactory<AdminDriverController>(
    () => AdminDriverController(
      getAllDriversUseCase: locator<GetAllDriversUseCase>(),
      approveDriverUseCase: locator<ApproveDriverUseCase>(),
      rejectDriverUseCase: locator<RejectDriverUseCase>(),
    ),
  );
   
   locator.registerFactory<AddProductsController>(
     () => AddProductsController(
       addProductUseCase: locator<AddProductUseCase>(),
     ),
   );  locator.registerFactory<EditProductController>(
    () => EditProductController(updateProductUseCase: locator<UpdateProductUseCase>()),
  );
  
  // Driver feature dependencies
  locator.registerFactory<DriverController>(
    () => DriverController(supabase: locator<SupabaseClient>()),
  );
}