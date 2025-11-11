import 'package:flutter/foundation.dart';
import '../data/cache_service.dart';
import '../data/models/login_response.dart';
import '../data/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repo;
  final CacheService _cache = CacheService();

  bool _loading = false;
  String? _token;
  String? _error;

  bool get loading => _loading;

  String? get token => _token;

  String? get error => _error;

  AuthViewModel(this._repo);

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repo.login(email, password);
      _token = result.token;
      if (_token != null) {
        await _cache.saveToken(_token!);
      }
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadCachedToken() async {
    _token = await _cache.getToken();
    notifyListeners();
  }

  Future<void> logout() async {
    await _cache.clearToken();
    _token = null;
    notifyListeners();
  }

  bool get isLoggedIn => _token != null;
}
