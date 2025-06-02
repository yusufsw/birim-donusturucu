import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Uygulamanın ilerleyen aşamalarında SQLite / Supabase / Firebase entegrasyonu
/// yapılmadan önce, yerel olarak basit kullanıcı işlemlerini gerçekleştirmek
/// için geçici bir yardımcı sınıf.  
///  
/// * Kullanıcı verileri SharedPreferences içerisinde `users` anahtarında
///   saklanan JSON listesi olarak tutulur.  
/// * **BU SINIF ÜRETİM İÇİN UYGUN DEĞİLDİR.** Sadece geliştirme sırasında
///   sayfaların derlenip çalışabilmesi için temel bir iskelet sunar.
class DatabaseHelper {
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  /// Kayıtlı tüm kullanıcıları getirir.
  Future<List<Map<String, dynamic>>> _getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? usersJson = prefs.getString('users');
    if (usersJson == null) return [];
    final List<dynamic> decoded = jsonDecode(usersJson);
    return decoded.cast<Map<String, dynamic>>();
  }

  /// Kullanıcı listesini kaydeder.
  Future<void> _saveUsers(List<Map<String, dynamic>> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('users', jsonEncode(users));
  }

  /// Yeni kullanıcı kaydeder.
  ///
  /// Eğer aynı kullanıcı adı daha önce kaydedildiyse `false` döner.
  Future<bool> registerUser(String username, String email, String password) async {
    final users = await _getUsers();

    final exists = users.any((u) => u['username'] == username);
    if (exists) return false;

    users.add({
      'username': username,
      'email': email,
      'password': password, // NOT: Şifreler düz metin olarak tutulmamalı.
    });

    await _saveUsers(users);
    return true;
  }

  /// Giriş kontrolü yapar. Başarılıysa `true` döner.
  Future<bool> loginUser(String username, String password) async {
    final users = await _getUsers();
    final user = users.firstWhere(
      (u) => u['username'] == username && u['password'] == password,
      orElse: () => {},
    );
    return user.isNotEmpty;
  }
} 