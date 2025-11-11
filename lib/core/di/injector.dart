import 'package:get_it/get_it.dart';
import '../network/api_client.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/user_viewmodel.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  getIt.registerLazySingleton<ApiClient>(() => ApiClient());

  getIt.registerLazySingleton<AuthRepository>(() => AuthRepository(getIt()));
  getIt.registerLazySingleton<UserRepository>(() => UserRepository(getIt()));

  getIt.registerFactory<AuthViewModel>(() => AuthViewModel(getIt()));
  getIt.registerFactory<UserViewModel>(() => UserViewModel(getIt()));
}
