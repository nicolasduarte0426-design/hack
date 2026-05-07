import 'package:local_auth/local_auth.dart';

class AuthService {
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> authenticate() async {
    try {

      // Verificar si el dispositivo soporta biometría
      bool isSupported = await auth.isDeviceSupported();

      print("SOPORTE: $isSupported");

      // Obtener biometrías disponibles
      List<BiometricType> biometrics =
          await auth.getAvailableBiometrics();

      print("BIOMETRIAS: $biometrics");

      if (!isSupported || biometrics.isEmpty) {
        return false;
      }

      bool authenticated = await auth.authenticate(
        localizedReason: 'Escanea tu huella para acceder',
      );

      print("AUTENTICADO: $authenticated");

      return authenticated;

    } catch (e) {
      print("ERROR: $e");
      return false;
    }
  }
}