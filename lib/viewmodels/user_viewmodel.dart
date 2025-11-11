import 'package:flutter/foundation.dart';
import '../data/models/user_model.dart';
import '../data/repositories/user_repository.dart';

class UserViewModel extends ChangeNotifier {
  final UserRepository _repo;

  UserViewModel(this._repo);

  bool _loading = false;
  List<UserModel> _users = [];

  bool get loading => _loading;
  List<UserModel> get users => _users;

  Future<void> loadUsers() async {
    _loading = true;
    notifyListeners();
    try {
      _users = await _repo.fetchUsers();
    } catch (e) {
      debugPrint('Error fetching users: \$e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
