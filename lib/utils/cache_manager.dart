import 'package:shared_preferences/shared_preferences.dart';

class CacheManager {
  //função para salvar dados do cache
  Future<void> saveToCache(String key, String data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, data);
  }

  // Recupera dados do cache usando a chave
  Future<String?> getFromCache(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }


  // Remove dados do cache usando a chave
  Future<void> removeFromCache(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  //limpa todo o cache
  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

}

