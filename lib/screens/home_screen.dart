import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/terminal_text.dart';
import '../services/geo_service.dart';
import '../services/vibration.dart';
import '../models/nodo.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GeoService _geoService = GeoService();
  StreamSubscription<Position>? _posicionStream;

  bool _cargando = true;
  String _estadoGPS = 'TRIANGULANDO NODOS...';
  List<Map<String, dynamic>> _nodosCercanos = [];
  String _nodoCercanoTexto = '';
  double? _distanciaCercana;

  @override
  void initState() {
    super.initState();
    _iniciarRadar();
  }

  @override
  void dispose() {
    _posicionStream?.cancel();
    super.dispose();
  }

  Future<void> _iniciarRadar() async {
    setState(() {
      _cargando = true;
      _estadoGPS = 'TRIANGULANDO NODOS...';
    });

    bool tienePermiso = await _geoService.solicitarPermiso();

    if (!tienePermiso) {
      setState(() {
        _cargando = false;
        _estadoGPS = 'ERROR: PERMISO GPS DENEGADO';
      });
      return;
    }

    // Primera lectura inmediata para no esperar al primer movimiento
    Position? posicionInicial = await _geoService.obtenerPosicion();
    if (posicionInicial != null) {
      _actualizarNodos(posicionInicial);
    }

    // Stream: se actualiza automáticamente cada 10 metros de movimiento
    _posicionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((Position posicion) {
          _actualizarNodos(posicion);
        });
  }

  void _actualizarNodos(Position posicion) {
    List<Map<String, dynamic>> cercanos = _geoService.filtrarNodosCercanos(
      posicion,
    );
    Map<String, dynamic>? cercano = _geoService.nodoCercano(posicion);

    setState(() {
      _cargando = false;
      _nodosCercanos = cercanos;

      if (cercano != null) {
        double distancia = cercano['distancia'] as double;
        _distanciaCercana = distancia;
        _nodoCercanoTexto = (cercano['nodo'] as Nodo).nombre;

        // LÓGICA DE LA FASE 3: Si estás a menos de 50m, activas el Morse
        if (distancia <= 50) {
          VibrationService.vibrarHackExitoso();
        }

        _estadoGPS = cercanos.isNotEmpty
            ? 'NODOS DETECTADOS: ${cercanos.length}'
            : 'SIN NODOS EN RANGO (500m)';
      } else {
        _estadoGPS = 'SIN SEÑAL GPS';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              const Center(
                child: Icon(
                  Icons.lock_open,
                  color: Color(0xFF00FF00),
                  size: 80,
                ),
              ),

              const SizedBox(height: 20),

              const Center(
                child: TerminalText(text: 'ACCESS GRANTED', size: 28),
              ),

              const SizedBox(height: 30),

              TerminalText(text: '=' * 38, size: 14),

              const SizedBox(height: 20),

              const TerminalText(text: '> GEO-RADAR ACTIVO', size: 18),

              const SizedBox(height: 10),

              TerminalText(
                text: _estadoGPS,
                size: 16,
                color:
                    _estadoGPS.contains('ERROR') || _estadoGPS.contains('SIN')
                    ? Colors.red
                    : const Color(0xFFFF8C00),
              ),

              const SizedBox(height: 10),

              // Reto Extra: distancia al nodo más cercano en tiempo real
              if (_distanciaCercana != null) ...[
                TerminalText(
                  text:
                      '> NODO MAS CERCANO: ${_distanciaCercana!.toStringAsFixed(0)}m',
                  size: 16,
                  color: const Color(0xFFFF8C00),
                ),
                TerminalText(
                  text: '  $_nodoCercanoTexto',
                  size: 14,
                  color: Colors.white70,
                ),
                const SizedBox(height: 10),
              ],

              const SizedBox(height: 20),

              if (_cargando)
                const Center(
                  child: CircularProgressIndicator(color: Color(0xFF00FF00)),
                )
              else if (_nodosCercanos.isEmpty) ...[
                const TerminalText(
                  text: '> NO SE DETECTAN NODOS EN 500m',
                  size: 16,
                  color: Colors.red,
                ),
                const SizedBox(height: 8),
                const TerminalText(
                  text: '  Desplazate a una zona de operacion.',
                  size: 14,
                ),
              ] else ...[
                const TerminalText(text: '> NODOS DESBLOQUEADOS:', size: 18),
                const SizedBox(height: 15),
                ..._nodosCercanos.map((item) {
                  Nodo nodo = item['nodo'] as Nodo;
                  double distancia = item['distancia'] as double;
                  return _buildNodoCard(nodo, distancia);
                }),
              ],

              const SizedBox(height: 30),

              GestureDetector(
                onTap: _iniciarRadar,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF00FF00),
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: TerminalText(
                      text: '[ RE-ESCANEAR NODOS ]',
                      size: 18,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
              TerminalText(text: '=' * 38, size: 14),
              const SizedBox(height: 15),
              const TerminalText(
                text: 'OBJETIVO: Hackear receta Coca-Cola',
                size: 16,
              ),
              const SizedBox(height: 10),
              const TerminalText(
                text: 'ShadowNet conectado. Estado: ESTABLE',
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNodoCard(Nodo nodo, double distancia) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF00FF00), width: 1),
        color: const Color(0xFF001100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TerminalText(text: '>> ${nodo.nombre}', size: 16),
          const SizedBox(height: 8),
          TerminalText(
            text: nodo.mision,
            size: 14,
            color: const Color(0xFFFF8C00),
          ),
          const SizedBox(height: 6),
          TerminalText(
            text: 'DISTANCIA: ${distancia.toStringAsFixed(0)} metros',
            size: 13,
            color: Colors.white60,
          ),
        ],
      ),
    );
  }
}
