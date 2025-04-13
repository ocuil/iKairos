import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/dracula.dart';

class CodeHighlighter extends StatelessWidget {
  final String code;
  final String language;
  final bool isDarkMode;

  const CodeHighlighter({
    Key? key,
    required this.code,
    required this.language,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barra superior con el nombre del lenguaje
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              color: isDarkMode ? Colors.grey[850] : Colors.grey[200],
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    language,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  // Botón para copiar el código
                  IconButton(
                    icon: Icon(
                      Icons.copy,
                      size: 16,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: code)).then((_) {
                        // Usar nuestra notificación personalizada en lugar del SnackBar
                        showCustomToast(
                          context, 
                          'Código copiado al portapapeles',
                          isDarkMode: isDarkMode
                        );
                      });
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Copiar código',
                  ),
                ],
              ),
            ),
            // El código resaltado
            HighlightView(
              code,
              language: language,
              theme: isDarkMode ? draculaTheme : githubTheme,
              padding: const EdgeInsets.all(12),
              textStyle: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Método para mostrar notificaciones personalizadas en la parte superior
void showCustomToast(BuildContext context, String message, {bool isSuccess = true, required bool isDarkMode}) {
  final overlay = Overlay.of(context);
  
  final toast = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 20,
      right: 20,
      child: Material(
        elevation: 10,
        borderRadius: BorderRadius.circular(16),
        shadowColor: isSuccess 
          ? const Color(0xFF3A86FF).withOpacity(0.3)
          : Colors.red.withOpacity(0.3),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isSuccess
                ? [
                    isDarkMode 
                      ? const Color(0xFF242433)
                      : Colors.white,
                    isDarkMode 
                      ? const Color(0xFF2A2A3D)
                      : const Color(0xFFF8FAFF),
                  ]
                : [
                    isDarkMode 
                      ? const Color(0xFF362936)
                      : const Color(0xFFFFF0F0),
                    isDarkMode 
                      ? const Color(0xFF2D242D)
                      : const Color(0xFFFFE6E6),
                  ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSuccess
                ? const Color(0xFF3A86FF).withOpacity(0.3)
                : Colors.red.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isSuccess 
                    ? const Color(0xFF3A86FF) 
                    : Colors.red).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isSuccess ? Icons.check_circle : Icons.info_outline,
                  color: isSuccess ? const Color(0xFF3A86FF) : Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode 
                      ? Colors.white 
                      : const Color(0xFF1A1A2A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
  
  overlay.insert(toast);
  
  // Remover el toast después de 2.5 segundos
  Future.delayed(const Duration(milliseconds: 2500), () {
    toast.remove();
  });
}