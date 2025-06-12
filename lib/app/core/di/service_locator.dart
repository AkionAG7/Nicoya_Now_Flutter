// lib/app/features/order/presentation/pages/order_detail_page.dart

import 'package:get_it/get_it.dart';
import 'package:nicoya_now/app/features/merchant/domain/usecases/update_merchant_address_usecase.dart';
import 'package:nicoya_now/app/features/order/presentation/controllers/change_order_status_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Core & shared
import 'package:nicoya_now/app/core/network/network_info.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:nicoya_now/app/core/services/role_service.dart';
import 'package:nicoya_now/app/core/services/notification_service.dart';

// Auth
import 'package:nicoya_now/app/features/auth/data/datasources/auth_data_source.dart';
import 'package:nicoya_now/app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:nicoya_now/app/features/auth/domain/repositories/auth_repository.dart';
import 'package:nicoya_now/app/features/auth/domain/usecases/add_user_role_usecase.dart';
import 'package:nicoya_now/app/features/auth/domain/usecases/get_user_roles_usecase.dart';
import 'package:nicoya_now/app/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:nicoya_now/app/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:nicoya_now/app/features/auth/presentation/controllers/auth_controller.dart';

// Merchant
import 'package:nicoya_now/app/features/merchant/data/datasources/merchant_data_source.dart';
import 'package:nicoya_now/app/features/merchant/data/repositories/merchant_repository_impl.dart';
import 'package:nicoya_now/app/features/merchant/domain/repositories/merchant_repository.dart';
import 'package:nicoya_now/app/features/merchant/domain/usecases/get_merchant_byowner_usecase.dart';
import 'package:nicoya_now/app/features/merchant/domain/usecases/register_merchant_usecase.dart';
import 'package:nicoya_now/app/features/merchant/presentation/controllers/merchant_registration_controller.dart';
import 'package:nicoya_now/app/features/merchant/presentation/controllers/merchant_settings_controller.dart';

// Products
import 'package:nicoya_now/app/features/products/data/datasources/products_data_source.dart';
import 'package:nicoya_now/app/features/products/data/repositories/products_repository_impl.dart';
import 'package:nicoya_now/app/features/products/domain/repositories/products_repository.dart';
import 'package:nicoya_now/app/features/products/domain/usecases/add_product_usecase.dart';
import 'package:nicoya_now/app/features/products/domain/usecases/delete_product_usecase.dart';
import 'package:nicoya_now/app/features/products/domain/usecases/update_product_usecase.dart';
import 'package:nicoya_now/app/features/products/presentation/controllers/add_product_controller.dart';
import 'package:nicoya_now/app/features/products/presentation/controllers/update_product_controller.dart';

// Orders
import 'package:nicoya_now/app/features/order/data/datasources/order_datasource.dart';
import 'package:nicoya_now/app/features/order/data/repositories/order_repository_impl.dart';
import 'package:nicoya_now/app/features/order/domain/repositories/order_repository.dart';
import 'package:nicoya_now/app/features/order/domain/usecases/change_order_status_usecase.dart';

// Admin – Merchant
import 'package:nicoya_now/app/features/admin/data/datasources/merchant/merchant_remote_datasource.dart';
import 'package:nicoya_now/app/features/admin/data/repositories/merchant/merchant_repository_impl.dart';
import 'package:nicoya_now/app/features/admin/domain/repositories/merchant/merchant_repository.dart'
    as AdminMerchantRepo;
import 'package:nicoya_now/app/features/admin/domain/usecases/merchant/merchant_usecases.dart';
import 'package:nicoya_now/app/features/admin/presentation/controllers/admin_merchant_controller.dart';

// Admin – Driver
import 'package:nicoya_now/app/features/admin/data/datasources/driver/driver_remote_datasource.dart';
import 'package:nicoya_now/app/features/admin/data/repositories/driver/driver_repository_impl.dart';
import 'package:nicoya_now/app/features/admin/domain/repositories/driver/driver_repository.dart';
import 'package:nicoya_now/app/features/admin/domain/usecases/driver/driver_usecases.dart';
import 'package:nicoya_now/app/features/admin/presentation/controllers/admin_driver_controller.dart';

// Driver
import 'package:nicoya_now/app/features/driver/presentation/controllers/driver_controller.dart';

final GetIt locator = GetIt.instance;

void setupServiceLocator() {
  // ───────────────────────────── External ──────────────────────────────
  if (!locator.isRegistered<SupabaseClient>()) {
    locator.registerSingleton<SupabaseClient>(Supabase.instance.client);
  }

  locator.registerLazySingleton<InternetConnectionChecker>(
    () => InternetConnectionChecker.createInstance(),
  );

  locator.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(
      connectionChecker: locator<InternetConnectionChecker>(),
    ),
  );

  // ───────────────────────────── Core ──────────────────────────────────
  locator.registerLazySingleton<RoleService>(
    () => RoleService(locator<SupabaseClient>()),
  );
  locator.registerLazySingleton<NotificationService>(
    () => NotificationService(),
  );

  // ───────────────────────────── DataSources ───────────────────────────
  locator
    ..registerLazySingleton<AuthDataSource>(
      () => SupabaseAuthDataSource(locator<SupabaseClient>()),
    )
    ..registerLazySingleton<MerchantDataSource>(
      () => SupabaseMerchantDataSource(locator<SupabaseClient>()),
    )
    ..registerLazySingleton<ProductsDataSource>(
      () => ProductsDataSourceImpl(supabaseClient: locator<SupabaseClient>()),
    )
    ..registerLazySingleton<OrderDatasource>(
      () => OrderDatasourceImpl(supabaseClient: locator<SupabaseClient>()),
    )
    ..registerLazySingleton<MerchantRemoteDataSource>(
      () => MerchantRemoteDataSourceImpl(supabase: locator<SupabaseClient>()),
    )
    ..registerLazySingleton<DriverRemoteDataSource>(
      () => DriverRemoteDataSourceImpl(supabase: locator<SupabaseClient>()),
    );

  // ───────────────────────────── Repositories ──────────────────────────
  locator
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(locator<AuthDataSource>()),
    )
    ..registerLazySingleton<MerchantRepository>(
      () => MerchantRepositoryImpl(locator<MerchantDataSource>()),
    )
    ..registerLazySingleton<ProductsRepository>(
      () => ProductsRepositoryImpl(dataSource: locator<ProductsDataSource>()),
    )
    ..registerLazySingleton<OrderRepository>(
      () => OrderRepositoryImpl(datasource: locator<OrderDatasource>()),
    )
    ..registerLazySingleton<AdminMerchantRepo.MerchantRepository>(
      () => AdminMerchantRepositoryImpl(
        remoteDataSource: locator<MerchantRemoteDataSource>(),
        networkInfo: locator<NetworkInfo>(),
      ),
    )
    ..registerLazySingleton<DriverRepository>(
      () => DriverRepositoryImpl(
        remoteDataSource: locator<DriverRemoteDataSource>(),
        networkInfo: locator<NetworkInfo>(),
      ),
    );

  // ───────────────────────────── UseCases ──────────────────────────────
  locator
    ..registerLazySingleton<SignInUseCase>(
      () => SignInUseCase(locator<AuthRepository>()),
    )
    ..registerLazySingleton<SignUpUseCase>(
      () => SignUpUseCase(locator<AuthRepository>()),
    )
    ..registerLazySingleton<GetUserRolesUseCase>(
      () => GetUserRolesUseCase(locator<AuthRepository>()),
    )
    ..registerLazySingleton<AddUserRoleUseCase>(
      () => AddUserRoleUseCase(locator<AuthRepository>()),
    )
    ..registerLazySingleton<RegisterMerchantUseCase>(
      () => RegisterMerchantUseCase(locator<MerchantRepository>()),
    )
    ..registerLazySingleton<GetMerchantByOwnerUseCase>(
      () => GetMerchantByOwnerUseCase(locator<MerchantRepository>()),
    )
    ..registerLazySingleton<AddProductUseCase>(
      () => AddProductUseCase(locator<ProductsRepository>()),
    )
    ..registerLazySingleton<UpdateProductUseCase>(
      () => UpdateProductUseCase(locator<ProductsRepository>()),
    )
    ..registerLazySingleton<DeleteProductUseCase>(
      () => DeleteProductUseCase(locator<ProductsRepository>()),
    )
    ..registerLazySingleton<ChangeOrderStatusUseCase>(
      () => ChangeOrderStatusUseCase(locator<OrderRepository>()),
    )
    // Admin – Merchant
    ..registerLazySingleton<GetAllMerchantsUseCase>(
      () => GetAllMerchantsUseCase(
        locator<AdminMerchantRepo.MerchantRepository>(),
      ),
    )  
      ..registerLazySingleton<ApproveMerchantUseCase>(
      () => ApproveMerchantUseCase(
        locator<AdminMerchantRepo.MerchantRepository>(),
      ),
    )
    ..registerLazySingleton<RejectMerchantUseCase>(
      () => RejectMerchantUseCase(
        locator<AdminMerchantRepo.MerchantRepository>(),
      ),
    )
      ..registerLazySingleton<UpdateMerchantAddress>(
    () => UpdateMerchantAddress(locator<MerchantRepository>()),
  )
    // Admin – Driver
    ..registerLazySingleton<GetAllDriversUseCase>(
      () => GetAllDriversUseCase(locator<DriverRepository>()),
    )
    ..registerLazySingleton<ApproveDriverUseCase>(
      () => ApproveDriverUseCase(locator<DriverRepository>()),
    )
    ..registerLazySingleton<RejectDriverUseCase>(
      () => RejectDriverUseCase(locator<DriverRepository>()),
    );

  // ───────────────────────────── Controllers ───────────────────────────
  locator
    // Auth
    ..registerFactory<AuthController>(
      () => AuthController(
        signInUseCase: locator<SignInUseCase>(),
        signUpUseCase: locator<SignUpUseCase>(),
        roleService: locator<RoleService>(),
        getUserRolesUseCase: locator<GetUserRolesUseCase>(),
        addUserRoleUseCase: locator<AddUserRoleUseCase>(),
      ),
    )
    // Merchant
    ..registerFactory<MerchantRegistrationController>(
      () => MerchantRegistrationController(
        registerMerchantUseCase: locator<RegisterMerchantUseCase>(),
      ),
    )
  ..registerFactory<MerchantSettingsController>(
    () => MerchantSettingsController(
      locator<GetMerchantByOwnerUseCase>(),
      locator<UpdateMerchantAddress>(),
    ),
  )
    // Products
    ..registerFactory<AddProductsController>(
      () => AddProductsController(
        addProductUseCase: locator<AddProductUseCase>(),
      ),
    )
    ..registerFactory<EditProductController>(
      () => EditProductController(
        updateProductUseCase: locator<UpdateProductUseCase>(),
      ),
    )
    // Orders
    ..registerFactory<ChangeOrderStatusController>(
      () => ChangeOrderStatusController(
        changeStatusUseCase: locator<ChangeOrderStatusUseCase>(),
      ),
    ) 
    // Admin – Merchant
    ..registerFactory<AdminMerchantController>(
      () => AdminMerchantController(
        getAllMerchantsUseCase: locator<GetAllMerchantsUseCase>(),
        approveMerchantUseCase: locator<ApproveMerchantUseCase>(),
        rejectMerchantUseCase: locator<RejectMerchantUseCase>(),
      ),
    )
    // Admin – Driver
    ..registerFactory<AdminDriverController>(
      () => AdminDriverController(
        getAllDriversUseCase: locator<GetAllDriversUseCase>(),
        approveDriverUseCase: locator<ApproveDriverUseCase>(),
        rejectDriverUseCase: locator<RejectDriverUseCase>(),
      ),
    )
    // Driver
    ..registerFactory<DriverController>(
      () => DriverController(supabase: locator<SupabaseClient>()),
    );
}
