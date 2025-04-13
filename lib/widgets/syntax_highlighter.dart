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
                        // Mostrar snackbar de confirmación
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Código copiado al portapapeles'),
                            duration: Duration(seconds: 2),
                          ),
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