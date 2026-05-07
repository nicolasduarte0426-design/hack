import 'package:local_auth/local_auth.dart';

class AuthService {
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> authenticate() async {
    try {
      bool canCheck = await auth.canCheckBiometrics;

      if (!canCheck) {
        return false;
      }

      bool authenticated = await auth.authenticate(
        localizedReason: 'Validar identidad para acceder a ShadowNet',
      );

      return authenticated;
    } catch (e) {
      return false;
    }
  }
}