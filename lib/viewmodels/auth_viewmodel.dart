import 'package:flutter/foundation.dart';
import '../data/cache_service.dart';
import '../data/models/login_response.dart';
import '../data/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repo;
  final CacheService _cache = CacheService();

  bool _loading = false;
  String? _token;
  String? _name;
  String? _error;

  bool get loading => _loading;

  String? get token => _token;

  String? get name => _name;

  String? get error => _error;

  AuthViewModel(this._repo);

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repo.login(email, password);
      _token = result.token;
      _name = result.name;
      if (_token != null) {
        await _cache.saveToken(_token!);
        await _cache.saveName(_name!);
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
    _name = await _cache.getName();
    notifyListeners();
  }

  Future<void> logout() async {
    await _cache.clearToken();
    await _cache.clearName();
    _token = null;
    _name = null;
    notifyListeners();
  }

  bool get isLoggedIn => _token != null;
}
