import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

// Função para salvar o token no SharedPreferences
Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('bearer_token', token);
  debugPrint('Token salvo: $token');
}

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
    return token;
  } catch (e) {
    debugPrint('Erro ao decodificar token: $e');
    return null;
  }
}

// Função para limpar o token do armazenamento
Future<void> clearToken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('bearer_token');
}
