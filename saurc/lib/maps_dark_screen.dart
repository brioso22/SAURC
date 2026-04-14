import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class MapsDarkScreen extends StatefulWidget {
  const MapsDarkScreen({super.key});

  @override
  State<MapsDarkScreen> createState() => _MapsDarkScreenState();
}

class _MapsDarkScreenState extends State<MapsDarkScreen> {
  LatLng? _userLocation;
  double _radioBusqueda = 5.0; 
  final MapController _mapController = MapController();
  final Distance _distanceCalculator = const Distance();

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    
    Position position = await Geolocator.getCurrentPosition();
    if (!mounted) return;
    setState(() {
      _userLocation = LatLng(position.latitude, position.longitude);
    });
  }

  void _regresarAMiUbicacion() {
    if (_userLocation != null) {
      _mapController.move(_userLocation!, 15.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Mapa de Transparencia", 
          style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w300)),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: _userLocation == null
          ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : Stack(
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('denuncias').snapshots(),
                  builder: (context, snapshot) {
                    List<Marker> markers = [];
                    if (snapshot.hasData) {
                      markers = snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final GeoPoint? geo = data['coordenadas'];
                        if (geo == null) return null;

                        final punto = LatLng(geo.latitude, geo.longitude);
                        final dist = _distanceCalculator.as(LengthUnit.Kilometer, _userLocation!, punto);
                        
                        // Solo mostramos denuncias dentro del radio del slider
                        if (dist > _radioBusqueda) return null;

                        return Marker(
                          point: punto,
                          width: 45,
                          height: 45,
                          child: GestureDetector(
                            onTap: () => _mostrarDetalle(context, data),
                            child: Icon(Icons.location_on, color: _getColor(data['estado']), size: 35),
                          ),
                        );
                      }).whereType<Marker>().toList();
                    }

                    return FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _userLocation!, 
                        initialZoom: 14,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.saurc.app.saurc',
                          tileProvider: NetworkTileProvider(),
                          tileBuilder: (context, tileWidget, tile) => ColorFiltered(
                            colorFilter: const ColorFilter.matrix([
                              -0.2126, -0.7152, -0.0722, 0, 255,
                              -0.2126, -0.7152, -0.0722, 0, 255,
                              -0.2126, -0.7152, -0.0722, 0, 255,
                              0, 0, 0, 1, 0,
                            ]),
                            child: tileWidget,
                          ),
                        ),
                        CircleLayer(
                          circles: [
                            CircleMarker(
                              point: _userLocation!,
                              radius: _radioBusqueda * 1000,
                              useRadiusInMeter: true,
                              color: Colors.blue.withOpacity(0.1),
                              borderColor: Colors.blueAccent.withOpacity(0.4),
                              borderStrokeWidth: 2,
                            ),
                          ],
                        ),
                        MarkerLayer(markers: markers),
                      ],
                    );
                  },
                ),
                
                // Botón para volver a ubicación actual (Ajuste 2)
                Positioned(
                  right: 20,
                  bottom: 120,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.blueAccent,
                    elevation: 5,
                    onPressed: _regresarAMiUbicacion,
                    child: const Icon(Icons.my_location, color: Colors.white),
                  ),
                ),

                // Control de Rango (Slider) - Ajuste 1
                Positioned(
                  bottom: 40, left: 20, right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.radar, color: Colors.blueAccent, size: 20),
                        Expanded(
                          child: Slider(
                            value: _radioBusqueda,
                            min: 0.5, max: 20.0,
                            activeColor: Colors.blueAccent,
                            inactiveColor: Colors.white24,
                            onChanged: (v) => setState(() => _radioBusqueda = v),
                          ),
                        ),
                        Text(
                          _radioBusqueda < 1 
                              ? "${(_radioBusqueda * 1000).toInt()}m" 
                              : "${_radioBusqueda.toStringAsFixed(1)}km",
                          style: const TextStyle(
                            color: Colors.white, 
                            fontSize: 12, 
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace' // Estilo técnico que te gusta
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
    );
  }

  Color _getColor(String? e) {
    if (e == 'Resuelto') return Colors.greenAccent;
    if (e == 'En Proceso') return Colors.orangeAccent;
    return Colors.redAccent;
  }

  void _mostrarDetalle(BuildContext context, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25))
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data['categoria'] ?? "Reporte", 
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Text(data['descripcion'] ?? "Sin descripción.", 
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}