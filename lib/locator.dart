import 'package:get_it/get_it.dart';
import 'package:mvvm_flutter_boilerplate/viewmodels/product_viewmodel.dart';

import 'core/db/app_database.dart';
import 'core/network/api_client.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/product_repository.dart';
import 'viewmodels/auth_viewmodel.dart';

final locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => ApiClient());
  locator.registerLazySingleton(() => AuthRepository(locator<ApiClient>()));
  locator.registerFactory(() => AuthViewModel(locator<AuthRepository>()));

  locator.registerLazySingleton(() => AppDatabase());
  locator.registerLazySingleton(() => ProductRepository(locator()));
  locator.registerFactory(() => ProductViewModel(locator<ProductRepository>()));
}
