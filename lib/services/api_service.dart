import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Servicio para comunicarse con la API de OpenWebUI.
class ApiService {
  // Obtener valores desde el archivo .env
  String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'https://';
  String get apiToken => dotenv.env['API_TOKEN'] ?? '';
  String get aiModel => dotenv.env['AI_MODEL'] ?? '';

  /// Envía un mensaje a la API de OpenWebUI y recibe la respuesta.
  /// 
  /// [message] es el mensaje del usuario.
  /// [systemPrompt] es el prompt del sistema que guía el comportamiento de la IA.
  /// 
  /// Devuelve un Future<String> con la respuesta de la IA.
  Future<String> sendMessage(String message, String systemPrompt) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiToken',
          'Accept': 'application/json; charset=utf-8',
        },
        body: jsonEncode({
          'model': aiModel, // Usando el valor del .env
          'messages': [
            {
              'role': 'system',
              'content': systemPrompt
            },
            {
              'role': 'user',
              'content': message
            }
          ],
          'stream': false,
          'temperature': 0.7,
          'max_tokens': 1000
        }),
      );
      
      if (response.statusCode == 200) {
        // Decodificar la respuesta correctamente con UTF-8
        final responseBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(responseBody);
        
        // La estructura exacta depende de la respuesta de la API
        final content = data['choices'][0]['message']['content'] ?? 'No se pudo obtener una respuesta';
        
        // Asegurar que el contenido esté correctamente codificado
        return content;
      } else {
        print('Error en la API: ${response.statusCode}');
        print('Respuesta: ${utf8.decode(response.bodyBytes)}');
        throw Exception('Error al comunicarse con la API: ${response.statusCode}');
      }
    } catch (e) {
      print('Excepción al llamar a la API: $e');
      throw Exception('No se pudo completar la llamada a la API: $e');
    }
  }
}