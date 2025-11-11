import '../../core/network/api_client.dart';
import '../models/user_model.dart';

class UserRepository {
  final ApiClient apiClient;

  UserRepository(this.apiClient);

  Future<List<UserModel>> fetchUsers() async {
    final response = await apiClient.get('users?page=1');
    final data = response.data['data'] as List<dynamic>;
    return data.map((e) => UserModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
