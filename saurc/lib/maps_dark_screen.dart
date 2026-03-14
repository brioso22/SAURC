import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapsDarkScreen extends StatelessWidget {
  const MapsDarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mapa de Transparencia", style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Esta línea es la "magia": escucha la misma colección donde PostCreate sube los datos
        stream: FirebaseFirestore.instance.collection('denuncias').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Error al cargar datos"));
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Transformamos cada documento de Firebase en un marcador del mapa
          final markers = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            
            // Extraemos el GeoPoint que creaste en PostCreateDarkScreen
            final GeoPoint? geoPoint = data['coordenadas'] as GeoPoint?;

            // Si por alguna razón el reporte no tiene coordenadas, saltamos ese punto
            if (geoPoint == null) return null;

            return Marker(
              point: LatLng(geoPoint.latitude, geoPoint.longitude),
              width: 45,
              height: 45,
              child: GestureDetector(
                onTap: () => _mostrarDetalleDenuncia(context, data, colors),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Icon(
                    Icons.location_on,
                    color: _getColorPorEstado(data['estado']), // Color dinámico según estado
                    size: 35,
                    shadows: const [
                      Shadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 2))
                    ],
                  ),
                ),
              ),
            );
          }).whereType<Marker>().toList(); // Limpiamos los nulos

          return FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(13.7942, -88.8965), // El Salvador
              initialZoom: 8.5,
              minZoom: 4,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.saurc.app.saurc',
                // Tu filtro de modo oscuro que tanto te gustó
                tileBuilder: (context, tileWidget, tile) {
                  return ColorFiltered(
                    colorFilter: const ColorFilter.matrix([
                      -0.2126, -0.7152, -0.0722, 0, 255,
                      -0.2126, -0.7152, -0.0722, 0, 255,
                      -0.2126, -0.7152, -0.0722, 0, 255,
                      0,       0,       0,       1, 0,
                    ]),
                    child: tileWidget,
                  );
                },
              ),
              MarkerLayer(markers: markers),
            ],
          );
        },
      ),
    );
  }

  // Función para dar color según el estado de la denuncia (Pendiente, Resuelto, etc.)
  Color _getColorPorEstado(String? estado) {
    switch (estado) {
      case 'Pendiente': return Colors.redAccent;
      case 'En Proceso': return Colors.orangeAccent;
      case 'Resuelto': return Colors.greenAccent;
      default: return Colors.blueAccent;
    }
  }

  // Muestra la información de la denuncia al tocar el punto
  void _mostrarDetalleDenuncia(BuildContext context, Map<String, dynamic> data, ColorScheme colors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(data['categoria'] ?? "Denuncia", 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                ),
                Chip(
                  label: Text(data['estado'] ?? "Pendiente", style: const TextStyle(fontSize: 12)),
                  backgroundColor: _getColorPorEstado(data['estado']).withOpacity(0.2),
                  side: BorderSide(color: _getColorPorEstado(data['estado'])),
                )
              ],
            ),
            const Divider(height: 30),
            Text("Descripción:", style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(data['descripcion'] == "" ? "Sin descripción detallada." : data['descripcion']),
            const SizedBox(height: 15),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: colors.onSurfaceVariant),
                const SizedBox(width: 8),
                Text("Por: ${data['nombre_usuario']}", style: TextStyle(color: colors.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}