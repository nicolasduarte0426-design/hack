import 'package:vibration/vibration.dart';

class VibrationService {
  static const List<int> _patronMorseH = [0, 150, 100, 150, 100, 150, 100, 150];

  static Future<void> vibrarHackExitoso() async {
    if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(pattern: _patronMorseH);
    }
  }

  static Future<void> vibrarError() async {
    if (await Vibration.hasVibrator() == true) {
      // Una vibración larga de 1 segundo para errores
      Vibration.vibrate(duration: 1000);
    }
  }
}
