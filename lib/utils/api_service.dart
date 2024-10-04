import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app/utils/cache_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class ApiService {
  final CacheManager cacheManager = CacheManager();

  // Função para obter o token do SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('bearer_token');

    if (token == null) {
      debugPrint('Token está nulo ou vazio.');
      return null;
    }

    // Decodifica o token para verificar informações (sem checar expiração)
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      debugPrint('Token decodificado: $decodedToken');

      // Apenas logue que o campo 'exp' não existe, e prossiga com o token
      if (decodedToken.containsKey('exp')) {
        final expirationTime = decodedToken['exp'];
        if (expirationTime != null) {
          final expTime = expirationTime.toString(); // Converte para String
          debugPrint('Token expira em: $expTime');
        } else {
          debugPrint('O campo "exp" é null.');
        }
      } else {
        debugPrint('O campo "exp" não existe no token.');
      }

      return token;
    } catch (e) {
      debugPrint('Erro ao decodificar token: $e');
      return null;
    }
  }

  // Função para salvar o token no SharedPreferences
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bearer_token', token);
    debugPrint('Token salvo: $token');
  }

  // Função para limpar o token do armazenamento
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('bearer_token');
  }

  Future<http.Response?> makeRequest({
    required String url,
    required String method,
    Map<String, String>? headers,
    dynamic body, // Permite que o body seja tanto Map quanto String
    bool useCache = false,
  }) async {
    try {
      final uri = Uri.parse(url);

      // Obtém o token armazenado
      String? token = await getToken();
      if (token != null) {
        headers ??= {};
        headers['Authorization'] = 'Bearer $token'; // Adiciona o token ao cabeçalho
      }

      // Define o Content-Type padrão se não estiver definido
      headers ??= {'Content-Type': 'application/json'};

      // Codifica o body se for Map, caso contrário, mantém a String
      final bodyData = (body is Map) ? jsonEncode(body) : body;

      final cacheKey = '$method:$url';

      // Verifica o cache antes de realizar a requisição
      if (useCache) {
        final cachedResponse = await cacheManager.getFromCache(cacheKey);
        if (cachedResponse != null) {
          return http.Response(cachedResponse, 200);
        }
      }

      // Realiza a requisição com base no método
      http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(uri, headers: headers, body: bodyData);
          break;
        case 'PUT':
          response = await http.put(uri, headers: headers, body: bodyData);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers, body: bodyData);
          break;
        default:
          throw Exception('Método HTTP não suportado');
      }

      // Armazena no cache se a resposta for bem-sucedida
      if (response.statusCode == 200) {
        await cacheManager.saveToCache(cacheKey, response.body);
      }

      return response;
    } catch (e) {
      print('Erro na requisição: $e');
      return null;
    }
  }

  Future<http.Response?> getWithAuth({
    required String url,
    bool useCache = false,
  }) async {
    return await makeRequest(
      url: url,
      method: 'GET',
      useCache: useCache,
    );
  }

  Future<http.Response?> postWithAuth({
    required String url,
    dynamic body,
    bool useCache = false,
  }) async {
    return await makeRequest(
      url: url,
      method: 'POST',
      body: body,
      useCache: useCache,
    );
  }
}
