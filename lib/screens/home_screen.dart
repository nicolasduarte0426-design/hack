import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/typewriter_text.dart';
import '../widgets/terminal_text.dart';
import '../services/audio_service.dart';
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
  bool _modoPanico = false;
  String _estadoGPS = 'TRIANGULANDO NODOS...';
  List<Map<String, dynamic>> _nodosCercanos = [];
  List<String> _kernelLogs = []; // Para los mensajes tipo Linux
  String _nodoCercanoTexto = '';
  double? _distanciaCercana;

  int _indiceNodoActual = 0;
  int _intentosFallidos = 0;
  bool _desafioAbierto = false; // Evita que el diálogo se abra muchas veces

  @override
  void initState() {
    super.initState();
    // Sonido de inicio de sistema ShadowNet
    AudioService.playEffect('access.mp3');
    _iniciarLogsKernel(); // Inicia la secuencia de mensajes
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

  void _iniciarLogsKernel() {
    _kernelLogs.addAll([
      'INICIANDO SHELL SHADOWNET...',
      'CARGANDO PROCESOS DE GEOLOCALIZACIÓN...',
      'RADAR HABILITADO',
    ]);
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

        _estadoGPS = cercanos.isNotEmpty
            ? cercanos.length == 1
                  ? 'NODO DETECTADO: 1'
                  : 'NODOS DETECTADOS: ${cercanos.length}'
            : 'SIN NODOS EN RANGO (500m)';
      } else {
        _estadoGPS = 'SIN SEÑAL GPS';
      }
    });

    _rastrearNodoActivo(posicion);
  }

  void _rastrearNodoActivo(Position posicionActual) {
    if (_indiceNodoActual < GeoService.nodos.length) {
      Nodo nodoObjetivo = GeoService.nodos[_indiceNodoActual];

      double distancia = _geoService.calcularDistancia(
        posicionActual,
        nodoObjetivo,
      );

      setState(() {
        _distanciaCercana = distancia;
        _nodoCercanoTexto = nodoObjetivo.nombre;
      });

      if (distancia <= 50 && !_desafioAbierto) {
        _mostrarPantallaHacker(nodoObjetivo);
      }
    } else {
      setState(() {
        _nodoCercanoTexto = 'SISTEMA TOTALMENTE HACKEADO';
      });
    }
  }

  void _comprobarRespuesta(String entrada, Nodo nodo) {
    String respuestaUser = entrada.toLowerCase().trim();

    if (respuestaUser == nodo.respuesta.toLowerCase()) {
      // --- ACIERTO ---
      Navigator.pop(context);
      AudioService.playEffect('radar.mp3');
      VibrationService.vibrarHackExitoso();

      setState(() {
        _indiceNodoActual++;
        _intentosFallidos = 0;
        _desafioAbierto = false;
        _kernelLogs.insert(0, '>>> ACCESO CONCEDIDO AL NODO: ${nodo.nombre}');
      });
    } else {
      // --- CADA RESPUESTA INCORRECTA ---
      setState(() {
        _intentosFallidos++;
      });

      // 1. Sonido de emergencia en cada error (1, 2 y 3)
      AudioService.playEmergency();

      if (_intentosFallidos >= 3) {
        // 2. AL CUMPLIR LA 3ra RESPUESTA INCORRECTA
        Navigator.pop(context); // Cierra el diálogo de la pregunta
        _mostrarAlertaDatosIncorrectos(); // Dispara la alerta de bloqueo
      } else {
        // Feedback visual/vibración para los intentos 1 y 2
        VibrationService.vibrarError();
      }
    }
  }

  void _mostrarAlertaDatosIncorrectos() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.red, width: 2),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text(
              'ALERTA DE SEGURIDAD',
              style: TextStyle(color: Colors.red, fontFamily: 'monospace'),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TerminalText(
              text:
                  'DATOS INCORRECTOS DETECTADOS.\n\nEL SISTEMA SE HA BLOQUEADO. INICIANDO PROTOCOLO DE AUTODESTRUCCIÓN DE DATOS.',
              color: Colors.red,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _ejecutarProtocoloReinicio(); // Ejecuta explosión y vuelve al Nodo Alpha
            },
            child: Text(
              '[ REINICIAR KERNEL ]',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _ejecutarProtocoloReinicio() async {
    // 1. Efecto final de explosión y vibración de 5 segundos
    await AudioService.playExplosion();
    VibrationService.vibrarAutodestruccion();

    setState(() {
      _indiceNodoActual = 0; // Bloquea el progreso y vuelve al primer nodo
      _intentosFallidos = 0;
      _desafioAbierto = false;
      _kernelLogs.insert(0, '!!! SISTEMA REINICIADO: VUELVA AL NODO ALPHA');
    });
  }

  void _mostrarPantallaHacker(Nodo nodo) {
    if (_desafioAbierto) return;
    _desafioAbierto = true;

    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        // Para que el diálogo se actualice al fallar
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.black,
          title: TerminalText(text: ">>> ${nodo.nombre}", color: Colors.green),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TerminalText(text: nodo.mision, size: 12),
              const Divider(color: Colors.green),
              TerminalText(text: nodo.pregunta),
              if (_intentosFallidos > 0)
                TerminalText(
                  text: "\nPISTA: ${nodo.pistas[_intentosFallidos - 1]}",
                  color: Colors.orange,
                  size: 11,
                ),
              TextField(
                controller: _controller,
                style: const TextStyle(
                  color: Colors.green,
                  fontFamily: 'monospace',
                ),
                decoration: const InputDecoration(
                  labelText: "INPUT CODE",
                  labelStyle: TextStyle(color: Colors.green),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _comprobarRespuesta(_controller.text, nodo);
                setDialogState(
                  () {},
                ); // Actualiza el diálogo para mostrar la pista
              },
              child: const TerminalText(text: "[ EJECUTAR ]"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF00FF41), width: 2),
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 10,
                  ),
                  color: const Color(0xFF00FF41),
                  child: const Text(
                    "TERMINAL - SHADOWNET OS v2.0.84",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Icon(
                            Icons.lock_open,
                            color: Color(0xFF00FF00),
                            size: 60,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: TypewriterText(
                            text: 'ACCESS GRANTED',
                            style: const TextStyle(
                              color: Color(0xFF00FF00),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                            duration: const Duration(milliseconds: 80),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildLinuxBanner(),
                        const SizedBox(height: 20),
                        TerminalText(text: '=' * 30, size: 12),
                        const SizedBox(height: 10),
                        TypewriterText(
                          text: '> GEO-RADAR ACTIVO',
                          style: const TextStyle(
                            color: Color(0xFFFF8C00),
                            fontSize: 16,
                            fontFamily: 'monospace',
                          ),
                          duration: const Duration(milliseconds: 40),
                        ),
                        const SizedBox(height: 10),
                        TerminalText(
                          text: _estadoGPS,
                          size: 16,
                          color:
                              _estadoGPS.contains('ERROR') ||
                                  _estadoGPS.contains('SIN')
                              ? Colors.red
                              : const Color(0xFFFF8C00),
                        ),
                        const SizedBox(height: 10),
                        if (_distanciaCercana != null) ...[
                          TerminalText(
                            text: 'OBJETIVO ACTUAL: ${_nodoCercanoTexto}',
                          ),
                          TerminalText(
                            text:
                                'DISTANCIA: ${_distanciaCercana!.toStringAsFixed(1)} mts',
                            color: Colors.yellow,
                          ),
                          TerminalText(
                            text:
                                'FASE DE HACKEO: ${_indiceNodoActual + 1} / ${GeoService.nodos.length}',
                            size: 10,
                          ),
                          const SizedBox(height: 10),
                        ],
                        const SizedBox(height: 20),
                        if (_cargando)
                          const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF00FF00),
                            ),
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
                          TerminalText(
                            text: _nodosCercanos.length == 1
                                ? '> NODO DETECTADO:'
                                : '> NODO MAS CERCANO:',
                            size: 18,
                          ),
                          const SizedBox(height: 15),
                          _buildNodoCard(
                            _nodosCercanos.first['nodo'] as Nodo,
                            _nodosCercanos.first['distancia'] as double,
                          ),
                        ],
                        const SizedBox(height: 30),
                        _buildBotonRescanear(),
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
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TerminalText(text: "root@shadowNet:~# _", size: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLinuxBanner() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const TerminalText(text: "KERNEL: v2.0.84-RELEASE", size: 12),
        const TerminalText(
          text: "OPERADOR: R.S.T correa.duarte.ramirez",
          size: 12,
        ),
        const TerminalText(text: "UBICACION: Sena CBA Mosquera", size: 12),
        TypewriterText(
          text: "FECHA: ${DateTime.now().toString().substring(0, 16)}",
          style: const TextStyle(
            color: Color(0xFF00FF41),
            fontSize: 12,
            fontFamily: 'monospace',
          ),
          duration: const Duration(milliseconds: 40),
        ),
        if (_modoPanico)
          const TerminalText(
            text: "MODO PANICO ACTIVADO",
            size: 12,
            color: Colors.red,
          ),
        const SizedBox(height: 5),
        const TerminalText(
          text: "STATUS: SYSTEM_READY",
          size: 12,
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildBotonRescanear() {
    return GestureDetector(
      onTap: _iniciarRadar,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF00FF00), width: 2),
        ),
        child: const Center(
          child: TerminalText(text: '[ RE-ESCANEAR NODOS ]', size: 18),
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
