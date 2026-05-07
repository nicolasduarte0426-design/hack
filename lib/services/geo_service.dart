import 'package:geolocator/geolocator.dart';
import '../models/nodo.dart';

class GeoService {

  /// Pide permiso de ubicación al usuario
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
}