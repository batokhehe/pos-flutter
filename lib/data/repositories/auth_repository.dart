import '../../core/network/api_client.dart';
import '../models/login_response.dart';

class AuthRepository {
  final ApiClient apiClient;

  AuthRepository(this.apiClient);

  Future<LoginResponse> login(String email, String password) async {
    final response = await apiClient.post('login', {
      'email': email,
      'password': password,
    });
    return LoginResponse.fromJson(response.data);
  }
}
