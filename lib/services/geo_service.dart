import 'package:geolocator/geolocator.dart';
import '../models/nodo.dart';

class GeoService {

  static const List<Nodo> nodos = [
    Nodo(
      nombre: 'NODO ALPHA — SENA Mosquera',
      mision: 'MISION: Hackear el servidor de notas',
      latitud: 4.7062,
      longitud: -74.2301,
    ),
    Nodo(
      nombre: 'NODO BETA — Parque Principal',
      mision: 'MISION: Interceptar señal de radio',
      latitud: 4.7082,
      longitud: -74.2275,
    ),
    Nodo(
      nombre: 'NODO GAMMA — Zona Industrial',
      mision: 'MISION: Sabotaje de drones',
      latitud: 4.7021,
      longitud: -74.2350,
    ),
  ];

  
  Future<bool> solicitarPermiso() async {
    LocationPermission permiso = await Geolocator.checkPermission();

    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
    }

    return permiso == LocationPermission.whileInUse ||
        permiso == LocationPermission.always;
  }

  /// Obtiene la posición actual del dispositivo
  Future<Position?> obtenerPosicion() async {
    bool tienePermiso = await solicitarPermiso();
    if (!tienePermiso) return null;

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (e) {
      return null;
    }
  }

  double calcularDistancia(Position posicion, Nodo nodo) {
    return Geolocator.distanceBetween(
      posicion.latitude,
      posicion.longitude,
      nodo.latitud,
      nodo.longitud,
    );
  }

  List<Map<String, dynamic>> filtrarNodosCercanos(Position posicion) {
    List<Map<String, dynamic>> resultado = [];

    for (Nodo nodo in nodos) {
      double distancia = calcularDistancia(posicion, nodo);
      if (distancia <= 500) {
        resultado.add({'nodo': nodo, 'distancia': distancia});
      }
    }

    resultado.sort((a, b) =>
        (a['distancia'] as double).compareTo(b['distancia'] as double));

    return resultado;
  }

  Map<String, dynamic>? nodoCercano(Position posicion) {
    if (nodos.isEmpty) return null;

    Nodo cercano = nodos[0];
    double menorDistancia = calcularDistancia(posicion, nodos[0]);

    for (Nodo nodo in nodos.skip(1)) {
      double distancia = calcularDistancia(posicion, nodo);
      if (distancia < menorDistancia) {
        menorDistancia = distancia;
        cercano = nodo;
      }
    }

    return {'nodo': cercano, 'distancia': menorDistancia};
  }
}