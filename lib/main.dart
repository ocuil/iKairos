import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/syntax_highlighter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  // Cargar las variables de entorno
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      });
    } catch (e) {
      debugPrint('Error al cargar preferencia de tema: $e');
    }
  }

  Future<void> _saveThemePreference(bool isDark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', isDark);
    } catch (e) {
      debugPrint('Error al guardar preferencia de tema: $e');
    }
  }

  void toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
      _saveThemePreference(_isDarkMode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iKairos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3A86FF),
          brightness: Brightness.light,
          primary: const Color(0xFF3A86FF),
          secondary: const Color(0xFF885AFF),
          tertiary: const Color(0xFFFF5ABB),
          surface: Colors.white,
          background: const Color(0xFFF9FAFC),
        ),
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF0F2F5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFF3A86FF), width: 1.5),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A1A1A),
          ),
          iconTheme: const IconThemeData(
            color: Color(0xFF1A1A1A),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3A86FF),
          brightness: Brightness.dark,
          primary: const Color(0xFF3A86FF),
          secondary: const Color(0xFF885AFF),
          tertiary: const Color(0xFFFF5ABB),
          surface: const Color(0xFF1F1F2C),
          background: const Color(0xFF0F0F1A),
          onBackground: Colors.white,
          onSurface: Colors.white,
        ),
        textTheme: GoogleFonts.interTextTheme(
          ThemeData.dark().textTheme,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1F1F2C),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFF3A86FF), width: 1.5),
          ),
          hintStyle: const TextStyle(color: Color(0xFF6C727F)),
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF1F1F2C),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3A86FF),
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF0F0F1A),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: ChatScreen(toggleTheme: toggleTheme, isDarkMode: _isDarkMode),
    );
  }
}

// Modelo simple para representar un mensaje en el chat
class ChatMessage {
  final String text;
  final bool isUserMessage;
  final bool isSystemMessage;

  ChatMessage({required this.text, required this.isUserMessage, this.isSystemMessage = false});

  // Convertir ChatMessage a JSON
  Map<String, dynamic> toJson() => {
    'text': text,
    'isUserMessage': isUserMessage,
    'isSystemMessage': isSystemMessage,
  };

  // Crear ChatMessage desde JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    text: json['text'] as String,
    isUserMessage: json['isUserMessage'] as bool,
    isSystemMessage: json['isSystemMessage'] as bool? ?? false, // Manejar posible nulidad si se añade después
  );
}

// Modelo para representar un chat guardado
class SavedChat {
  String title; // Hacer mutable para permitir renombrar
  final List<ChatMessage> messages;
  final DateTime timestamp;

  SavedChat({
    required this.title,
    required this.messages,
    required this.timestamp,
  });

  // Convertir SavedChat a JSON
  Map<String, dynamic> toJson() => {
    'title': title,
    'messages': messages.map((msg) => msg.toJson()).toList(),
    'timestamp': timestamp.toIso8601String(), // Guardar fecha como string
  };

  // Crear SavedChat desde JSON
  factory SavedChat.fromJson(Map<String, dynamic> json) => SavedChat(
    title: json['title'] as String,
    messages: (json['messages'] as List<dynamic>)
        .map((msgJson) => ChatMessage.fromJson(msgJson as Map<String, dynamic>))
        .toList(),
    timestamp: DateTime.parse(json['timestamp'] as String), // Parsear fecha desde string
  );
}

class ChatScreen extends StatefulWidget {
  final Function toggleTheme;
  final bool isDarkMode;

  const ChatScreen({super.key, required this.toggleTheme, required this.isDarkMode});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService(); // Instancia del servicio

  List<ChatMessage> _currentMessages = [];
  List<SavedChat> _savedChats = []; // Cambiar a no final para poder reasignar al cargar
  bool _isLoading = false;

  Map<String, double> _personalityParams = { // Cambiar a no final
    'Sarcasmo': 0.3,
    'Entusiasmo': 0.6,
    'Formalidad': 0.7,
    'Humor': 0.5,
    'Empatía': 0.8,
  };

  // Obtener la plantilla del system prompt desde las variables de entorno
  String get _systemPromptTemplate => dotenv.env['SYSTEM_PROMPT_TEMPLATE'] ?? 'Eres un asistente de chatbot que responde a las preguntas del usuario.'; // Texto por defecto reducido

  // Genera el system prompt completo reemplazando los placeholders
  String _generateSystemPrompt() {
    String prompt = _systemPromptTemplate;
    
    // Reemplazar cada placeholder con su valor actual
    _personalityParams.forEach((param, value) {
      final placeholder = '{{${param.toUpperCase()}}}';
      prompt = prompt.replaceAll(placeholder, value.toString());
    });
    
    return prompt;
  }

  @override
  void initState() {
    super.initState();
    _loadData(); // Cargar datos al iniciar el estado
  }

  // Cargar datos guardados
  Future<void> _loadData() async {
    final loadedChats = await _storageService.loadChats();
    final loadedParams = await _storageService.loadPersonalityParams();
    
    setState(() {
      _savedChats = loadedChats;
      if (loadedParams != null) {
        _personalityParams = loadedParams;
      }
      // Opcional: Cargar el último chat guardado o uno específico al inicio
      // if (_savedChats.isNotEmpty) {
      //   _currentMessages = List<ChatMessage>.from(_savedChats.last.messages);
      // }
    });
  }

  // Guardar todos los datos relevantes (chats y parámetros)
  Future<void> _saveAllData() async {
    await _storageService.saveChats(_savedChats);
    await _storageService.savePersonalityParams(_personalityParams);
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    // Verificar si el mensaje es un comando de parámetros
    if (message.startsWith('/parametros ')) {
      _handleParametersCommand(message);
      return;
    }

    // Añadir el mensaje del usuario al chat
    setState(() {
      _currentMessages.add(ChatMessage(text: message, isUserMessage: true));
      _messageController.clear();
      _isLoading = true; // Comenzar a mostrar indicador de carga
    });

    try {
      // Obtener el system prompt dinámico actualizado
      final systemPrompt = _generateSystemPrompt();
      
      // Llamar a la API para obtener la respuesta
      final response = await _apiService.sendMessage(message, systemPrompt);
      
      // Añadir la respuesta de la IA al chat
      setState(() {
        _currentMessages.add(ChatMessage(text: response, isUserMessage: false));
        _isLoading = false; // Ocultar indicador de carga
      });
    } catch (e) {
      // Manejar errores
      setState(() {
        _currentMessages.add(ChatMessage(
          text: "Error al comunicarse con la IA: ${e.toString()}",
          isUserMessage: false,
        ));
        _isLoading = false; // Ocultar indicador de carga
      });
    }
  }

  // Maneja el comando /parametros
  void _handleParametersCommand(String command) {
    // Separar el comando en partes: /parametros Parámetro Valor
    final parts = command.split(' ');
    
    if (parts.length != 3) {
      _showParameterMessage('Formato incorrecto. Usa: /parametros [Parámetro] [Valor]');
      return;
    }
    
    final paramName = parts[1]; // El nombre del parámetro
    final paramValueStr = parts[2]; // El valor como string
    
    // Verificar si el parámetro existe
    if (!_personalityParams.containsKey(paramName)) {
      _showParameterMessage('Parámetro no reconocido: "$paramName". Parámetros disponibles: ${_personalityParams.keys.join(", ")}');
      return;
    }
    
    // Convertir y validar el valor
    double? paramValue = double.tryParse(paramValueStr);
    if (paramValue == null || paramValue < 0.0 || paramValue > 1.0) {
      _showParameterMessage('Valor no válido: "$paramValueStr". Debe ser un número entre 0.0 y 1.0');
      return;
    }
    
    // Actualizar el parámetro
    setState(() {
      _personalityParams[paramName] = paramValue;
      _showParameterMessage('Parámetro "$paramName" actualizado a $paramValue');
    });
    _saveAllData(); // Guardar parámetros actualizados
    
    // Limpiar el campo de texto
    _messageController.clear();
  }
  
  // Añade un mensaje de sistema sobre parámetros
  void _showParameterMessage(String message) {
    setState(() {
      _currentMessages.add(ChatMessage(
        text: message,
        isUserMessage: false,
        isSystemMessage: true,
      ));
    });
  }

  // Guardar el chat actual
  void _saveCurrentChat() {
    if (_currentMessages.isEmpty) {
      // No guardar chats vacíos
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay mensajes para guardar')),
      );
      return;
    }

    // Mostrar diálogo para que el usuario ingrese un nombre para el chat
    final TextEditingController titleController = TextEditingController(
      text: 'Chat ${_savedChats.length + 1}' // Nombre predeterminado
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Guardar Chat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ingresa un nombre para este chat:'),
            const SizedBox(height: 10),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Nombre del chat'
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar el diálogo sin guardar
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final chatTitle = titleController.text.trim().isNotEmpty
                  ? titleController.text.trim()
                  : 'Chat ${_savedChats.length + 1}';
                  
              final now = DateTime.now();
              
              // Crear una copia profunda de los mensajes actuales
              final messagesCopy = List<ChatMessage>.from(_currentMessages);
              
              // Crear y guardar el nuevo chat
              final newChat = SavedChat(
                title: chatTitle,
                messages: messagesCopy,
                timestamp: now,
              );
              
              setState(() {
                _savedChats.add(newChat);
              });
              _saveAllData(); // Guardar la lista de chats actualizada
              
              Navigator.pop(context); // Cerrar el diálogo
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Chat guardado como "$chatTitle"')),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
  
  // Cargar un chat guardado
  void _loadSavedChat(int index) {
    if (index < 0 || index >= _savedChats.length) return;
    
    final savedChat = _savedChats[index];
    
    setState(() {
      // Copiar los mensajes del chat guardado al chat actual
      _currentMessages = List<ChatMessage>.from(savedChat.messages);
    });
    
    // Cerrar el drawer
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Chat "${savedChat.title}" cargado')),
    );
  }
  
  // Formatear fecha para mostrar en la UI
  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    
    return '$day/$month $hour:$minute';
  }
  
  // Confirmar y borrar todo el historial
  void _confirmDeleteHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Borrar historial'),
        content: const Text('¿Estás seguro de que quieres borrar todos los chats guardados? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar el diálogo
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              // Borrar todos los chats guardados
              setState(() {
                _savedChats.clear();
              });
              _storageService.clearAllData(); // Usar el método del servicio para borrar
              
              Navigator.pop(context); // Cerrar el diálogo
              Navigator.pop(context); // Cerrar el drawer
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Historial borrado')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
  }

  // Iniciar un nuevo chat
  void _startNewChat() {
    // Verificar si hay mensajes en el chat actual
    if (_currentMessages.isNotEmpty) {
      // Preguntar al usuario si desea guardar el chat actual antes de iniciar uno nuevo
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Nuevo Chat'),
          content: const Text('¿Deseas guardar el chat actual antes de iniciar uno nuevo?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar el diálogo
                setState(() {
                  _currentMessages = []; // Limpiar mensajes sin guardar
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nuevo chat iniciado')),
                );
              },
              child: const Text('No guardar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cerrar el diálogo
                _saveCurrentChat(); // Guardar chat actual
                setState(() {
                  _currentMessages = []; // Limpiar mensajes para nuevo chat
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chat guardado y nuevo chat iniciado')),
                );
              },
              child: const Text('Guardar y continuar'),
            ),
          ],
        ),
      );
    } else {
      // Si no hay mensajes, simplemente mostrar una notificación
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nuevo chat iniciado')),
      );
    }
  }

  // Borrar un chat guardado
  void _deleteSavedChat(int index) {
    setState(() {
      _savedChats.removeAt(index);
    });
    _saveAllData(); // Guardar la lista de chats actualizada
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chat eliminado')),
    );
  }

  // Renombrar un chat guardado
  void _renameSavedChat(int index) {
    final chat = _savedChats[index];
    final TextEditingController titleController = TextEditingController(text: chat.title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Renombrar Chat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ingresa un nuevo nombre para este chat:'),
            const SizedBox(height: 10),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Nombre del chat'
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar el diálogo sin guardar
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final newTitle = titleController.text.trim();
              if (newTitle.isNotEmpty) {
                setState(() {
                  _savedChats[index] = SavedChat(
                    title: newTitle,
                    messages: chat.messages,
                    timestamp: chat.timestamp,
                  );
                });
                _saveAllData(); // Guardar la lista de chats actualizada
                Navigator.pop(context); // Cerrar el diálogo
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Chat renombrado a "$newTitle"')),
                );
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Opcional: Guardar datos al cerrar la pantalla si es necesario,
    // aunque es mejor guardar después de cada cambio significativo.
    // _saveAllData(); 
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Image.asset(
                'assets/images/icon.png',
                width: 30,
                height: 30,
              ),
            ),
            const Text(
              'iKairos',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 2,
        shadowColor: Theme.of(context).shadowColor.withOpacity(0.3),
        actions: [
          // Botón para nuevo chat
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Nuevo Chat',
            onPressed: _startNewChat,
            style: IconButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          // Botón para guardar el chat actual
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Guardar Chat',
            onPressed: _saveCurrentChat,
            style: IconButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          // Botón para cambiar el tema
          IconButton(
            icon: widget.isDarkMode 
                ? const Icon(Icons.light_mode_outlined)
                : const Icon(Icons.dark_mode_outlined),
            tooltip: widget.isDarkMode ? 'Modo Claro' : 'Modo Oscuro',
            onPressed: () => widget.toggleTheme(),
            style: IconButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: const Text(
                'Historial de Chats',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            
            // Mostrar chats guardados
            if (_savedChats.isEmpty)
              const ListTile(
                title: Text('No hay chats guardados'),
                subtitle: Text('Guarda un chat usando el botón de guardar'),
              )
            else
              ..._savedChats.asMap().entries.map((entry) {
                final index = entry.key;
                final chat = entry.value;
                return Dismissible(
                  key: Key('chat_$index'),
                  background: Container(
                    color: Colors.blue,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20.0),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  direction: DismissDirection.horizontal,
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.endToStart) {
                      // Deslizado hacia la izquierda: Eliminar
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Confirmar eliminación"),
                            content: Text("¿Seguro que quieres eliminar \"${chat.title}\"?"),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text("Cancelar"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text(
                                  "Eliminar",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      // Deslizado hacia la derecha: Editar nombre
                      _renameSavedChat(index);
                      return false; // No eliminar el elemento
                    }
                  },
                  onDismissed: (direction) {
                    if (direction == DismissDirection.endToStart) {
                      _deleteSavedChat(index);
                    }
                  },
                  child: ListTile(
                    leading: const Icon(Icons.chat),
                    title: Text(chat.title),
                    subtitle: Text('${chat.messages.length} mensajes • ${_formatDate(chat.timestamp)}'),
                    onTap: () => _loadSavedChat(index),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _renameSavedChat(index),
                      tooltip: 'Editar nombre',
                    ),
                  ),
                );
              }),
              
            if (_savedChats.isNotEmpty) const Divider(),
            
            // Opción para borrar todo el historial
            ListTile(
              leading: const Icon(Icons.delete_forever),
              title: const Text('Borrar Historial'),
              enabled: _savedChats.isNotEmpty,
              onTap: _confirmDeleteHistory,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Lista de mensajes
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _currentMessages.length,
              itemBuilder: (context, index) {
                final message = _currentMessages[index];
                
                // Estilo especial para mensajes del sistema
                if (message.isSystemMessage) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: widget.isDarkMode 
                        ? Colors.amber.withOpacity(0.2)
                        : Colors.amber[100],
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(
                        color: widget.isDarkMode 
                          ? Colors.amber.withOpacity(0.5)
                          : Colors.amber[300]!,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: widget.isDarkMode 
                          ? Colors.amber[200]
                          : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                
                // Mensajes normales (usuario o IA)
                return Align(
                  alignment: message.isUserMessage
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 2.0),
                    padding: message.isUserMessage
                        ? const EdgeInsets.all(14.0)
                        : const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.80,
                    ),
                    decoration: BoxDecoration(
                      color: message.isUserMessage
                          ? (widget.isDarkMode 
                              ? const Color(0xFF3A86FF).withOpacity(0.25)
                              : const Color(0xFFE3F0FF))
                          : (widget.isDarkMode 
                              ? const Color(0xFF1F1F2C)
                              : Colors.white),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18.0),
                        topRight: const Radius.circular(18.0),
                        bottomLeft: message.isUserMessage 
                            ? const Radius.circular(18.0) 
                            : const Radius.circular(4.0),
                        bottomRight: message.isUserMessage 
                            ? const Radius.circular(4.0) 
                            : const Radius.circular(18.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(
                        color: message.isUserMessage
                            ? (widget.isDarkMode 
                                ? const Color(0xFF3A86FF).withOpacity(0.3)
                                : const Color(0xFFCCE4FF))
                            : (widget.isDarkMode 
                                ? const Color(0xFF282836)
                                : const Color(0xFFF0F2F5)),
                        width: 1,
                      ),
                    ),
                    child: message.isUserMessage
                        // Texto simple para mensajes del usuario
                        ? Text(message.text)
                        // Markdown para mensajes de la IA
                        : MarkdownBody(
                            data: message.text,
                            selectable: true,
                            styleSheet: MarkdownStyleSheet(
                              p: TextStyle(
                                fontSize: 15.0,
                                color: Theme.of(context).colorScheme.onBackground,
                              ),
                              h1: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              h2: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              h3: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onBackground,
                              ),
                              code: TextStyle(
                                backgroundColor: widget.isDarkMode ? Colors.grey[800] : Colors.grey[200],
                                fontFamily: 'monospace',
                                fontSize: 14.0,
                                color: widget.isDarkMode ? Colors.grey[300] : Colors.black87,
                              ),
                              blockquote: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
                              ),
                              blockquoteDecoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4.0),
                                border: Border(
                                  left: BorderSide(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                                    width: 4.0,
                                  ),
                                ),
                              ),
                              listBullet: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 16.0,
                              ),
                              tableHead: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onBackground,
                              ),
                              tableBorder: TableBorder.all(
                                color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                                width: 1,
                              ),
                              tableBody: TextStyle(
                                color: Theme.of(context).colorScheme.onBackground,
                              ),
                              a: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            onTapLink: (text, href, title) {
                              if (href != null) {
                                // Aquí podrías implementar la apertura de enlaces
                                // Por ejemplo, usando url_launcher
                                debugPrint('Enlace tapeado: $href');
                              }
                            },
                            builders: {
                              'code': CodeBlockBuilder(
                                isDarkMode: widget.isDarkMode,
                              ),
                            },
                          ),
                  ),
                );
              },
            ),
          ),
          
          // Indicador de carga
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Pensando...',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          
          // Barra de entrada de mensajes
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            decoration: BoxDecoration(
              color: widget.isDarkMode 
                ? const Color(0xFF1A1A2A) 
                : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
              border: Border(
                top: BorderSide(
                  color: widget.isDarkMode 
                    ? const Color(0xFF282836) 
                    : const Color(0xFFEAECF0),
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Campo de texto
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24.0),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).shadowColor.withOpacity(0.04),
                            spreadRadius: 0,
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Escribe un mensaje...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                          filled: true,
                          fillColor: widget.isDarkMode 
                            ? const Color(0xFF242433) 
                            : const Color(0xFFF5F7FA),
                          hintStyle: TextStyle(
                            color: widget.isDarkMode 
                              ? Colors.grey[400] 
                              : Colors.grey[600],
                            fontSize: 15.0,
                          ),
                          prefixIcon: Icon(
                            Icons.chat_bubble_outline,
                            color: widget.isDarkMode 
                              ? Colors.grey[500] 
                              : Colors.grey[600],
                            size: 20,
                          ),
                        ),
                        style: TextStyle(
                          color: widget.isDarkMode 
                            ? Colors.white 
                            : Colors.black87,
                          fontSize: 15.0,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12.0),
                  
                  // Botón de enviar
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3A86FF), Color(0xFF5F72FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF3A86FF).withOpacity(0.4),
                          spreadRadius: 0,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Constructor de bloques de código para Markdown
class CodeBlockBuilder extends MarkdownElementBuilder {
  final bool isDarkMode;

  CodeBlockBuilder({required this.isDarkMode});

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    var language = '';
    
    if (element.attributes.containsKey('class')) {
      var lg = element.attributes['class']!.split('-');
      if (lg.length > 1) {
        language = lg[1];
      }
    }
    
    return CodeHighlighter(
      code: element.textContent,
      language: language.isNotEmpty ? language : 'plaintext',
      isDarkMode: isDarkMode,
    );
  }
}
