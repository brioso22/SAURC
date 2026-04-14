import 'package:flutter/material.dart';

class HelpDarkScreen extends StatelessWidget {
  const HelpDarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Detectamos el color de texto que corresponde al tema actual (negro en modo claro, blanco en oscuro)
    final Color textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    // Un color secundario para las respuestas (grisáceo)
    final Color subTextColor = Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7) ?? Colors.grey;

    final List<Map<String, String>> faqs = [
      {'pregunta': '¿Qué es SAURC y cuál es su objetivo?', 'respuesta': 'SAURC es una plataforma diseñada para el monitoreo y reporte de incidencias en tiempo real, facilitando la comunicación y la seguridad comunitaria.'},
      {'pregunta': '¿Cómo puedo realizar una denuncia?', 'respuesta': 'Ve a la pestaña "Denunciar" en la barra inferior, completa el formulario con los detalles y presiona enviar.'},
      {'pregunta': '¿Mis datos personales están seguros?', 'respuesta': 'Sí, utilizamos cifrado de extremo a extremo para proteger tu información personal y reportes.'},
      {'pregunta': '¿Necesito conexión a internet?', 'respuesta': 'Para enviar reportes en tiempo real es necesaria una conexión activa. Si no tienes, el reporte se enviará al recuperar la señal.'},
      {'pregunta': '¿Puedo adjuntar pruebas multimedia?', 'respuesta': 'Sí, puedes adjuntar fotos y videos cortos para dar más detalle a la incidencia reportada.'},
      {'pregunta': '¿Cómo veo el estado de mis reportes?', 'respuesta': 'En la sección "Posts" puedes visualizar el seguimiento de tus denuncias y verificar si han sido procesadas.'},
      {'pregunta': '¿SAURC rastrea mi ubicación siempre?', 'respuesta': 'No. Solo accede al GPS cuando realizas un reporte o si activas alertas cercanas en configuración.'},
      {'pregunta': '¿Cómo contacto al soporte técnico?', 'respuesta': 'Puedes escribirnos directamente a través del botón de contacto en la pestaña de Configuración.'},
      {'pregunta': '¿La aplicación tiene algún costo?', 'respuesta': 'No, SAURC es una herramienta completamente gratuita para el beneficio de la comunidad.'},
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            "Preguntas Frecuentes",
            style: TextStyle(
              color: textColor, // Ahora es adaptativo
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: faqs.length,
            itemBuilder: (context, index) {
              return Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  leading: const Icon(Icons.help_outline, color: Colors.blueAccent),
                  title: Text(
                    faqs[index]['pregunta']!,
                    style: TextStyle(
                      color: textColor, // Ahora es adaptativo
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  iconColor: Colors.blueAccent,
                  collapsedIconColor: Colors.grey,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 70, right: 20, bottom: 15),
                      child: Text(
                        faqs[index]['respuesta']!,
                        style: TextStyle(
                          color: subTextColor, // Ahora es adaptativo
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}