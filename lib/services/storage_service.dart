import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../main.dart'; // Importar para acceder a los modelos ChatMessage y SavedChat

/// Servicio para manejar el almacenamiento persistente de la aplicación
class StorageService {
  static const String _savedChatsKey = 'saved_chats';
  static const String _personalityParamsKey = 'personality_params';

  /// Guarda la lista de chats en el almacenamiento local
  Future<bool> saveChats(List<SavedChat> chats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Convertir la lista de SavedChat a una lista de Mapas usando toJson
      final List<Map<String, dynamic>> chatsJson = chats.map((chat) => chat.toJson()).toList();
      final jsonString = jsonEncode(chatsJson);
      return await prefs.setString(_savedChatsKey, jsonString);
    } catch (e) {
      debugPrint('Error al guardar chats: $e');
      return false;
    }
  }

  /// Carga la lista de chats desde el almacenamiento local
  Future<List<SavedChat>> loadChats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_savedChatsKey);
      
      if (jsonString == null) {
        return []; // Devolver lista vacía si no hay nada guardado
      }
      
      final List<dynamic> decodedList = jsonDecode(jsonString);
      // Convertir la lista de Mapas de vuelta a una lista de SavedChat usando fromJson
      final List<SavedChat> chats = decodedList
          .map((chatJson) => SavedChat.fromJson(chatJson as Map<String, dynamic>))
          .toList();
      return chats;
    } catch (e) {
      debugPrint('Error al cargar chats: $e');
      // En caso de error (p.ej., formato inválido), devolver lista vacía
      return []; 
    }
  }

  /// Guarda los parámetros de personalidad
  Future<bool> savePersonalityParams(Map<String, double> params) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Los mapas de String a double se pueden codificar directamente a JSON
      final jsonString = jsonEncode(params);
      return await prefs.setString(_personalityParamsKey, jsonString);
    } catch (e) {
      debugPrint('Error al guardar parámetros de personalidad: $e');
      return false;
    }
  }

  /// Carga los parámetros de personalidad
  Future<Map<String, double>?> loadPersonalityParams() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_personalityParamsKey);
      
      if (jsonString == null) {
        return null; // Devolver null si no hay parámetros guardados
      }
      
      final Map<String, dynamic> decodedMap = jsonDecode(jsonString);
      // Convertir los valores de vuelta a double
      final Map<String, double> params = decodedMap.map((key, value) => MapEntry(key, (value as num).toDouble()));
      return params;
    } catch (e) {
      debugPrint('Error al cargar parámetros de personalidad: $e');
      return null; // Devolver null en caso de error
    }
  }

  /// Borra todos los datos guardados (chats y parámetros)
  Future<bool> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Borrar específicamente las claves que usamos
      await prefs.remove(_savedChatsKey);
      await prefs.remove(_personalityParamsKey);
      // Opcionalmente, podrías usar prefs.clear() para borrar todo, pero es más seguro borrar solo lo conocido
      return true;
    } catch (e) {
      debugPrint('Error al borrar datos: $e');
      return false;
    }
  }
}