import 'package:geolocator/geolocator.dart';
import '../models/nodo.dart';

class GeoService {

 static List<Nodo> nodos = [
  // NODO 1: SENA CBA (Sede Mosquera)
  Nodo(
    nombre: 'NODO ALPHA – sena bloque c',
    mision: 'MISION: Robar informacion de los ingredientes',
    latitud: 4.695216,
    longitud: -74.217058,
    pregunta: '¿Cual es el nombre que recibe la coca-cola sin azucar?',
    respuesta: 'zero',
    pistas: [
      'tiene tapa negra',
      'El nombre contiene un numero escrito',
      'Z _ _ O'
    ],
  ),

  // NODO 2: Parque Principal de Mosquera
  Nodo(
    nombre: 'NODO BETA – parque principal',
    mision: 'MISION: Obtencion del ingrediente secreto',
    latitud: 4.712315,
    longitud: -74.220820,
    pregunta: '¿Cual es el animal representativo de coca-cola?',
    respuesta: 'oso polar',
    pistas: [
      'representa la navidad',
      'esta en peligro de extincion',
      'O _ _   _ _ _ _ R '
    ],
  ),

  // NODO 3: Zona Industrial (Cerca de planta de producción)
  Nodo(
    nombre: 'NODO GAMMA – zona industrial',
    mision: 'MISION: sabotaje de la preparacion',
    latitud: 4.704962,
    longitud: -74.230212,
    pregunta: '¿cual es el principal competidor de coca-cola?',
    respuesta: 'pepsi',
    pistas: [
      'su color representativo es azul',
      'tuvo a michael jackson como imagen',
      'P _ _ _ I'
    ],
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