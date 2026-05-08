import 'package:audioplayers/audioplayers.dart';

class AudioService {
  // Una sola instancia para todo el sistema (Singleton manual)
  static final AudioPlayer _player = AudioPlayer();

  // Función para sonidos cortos de interfaz
  static Future<void> playEffect(String fileName) async {
    try {
      // AssetSource busca automáticamente dentro de la carpeta assets registrada
      await _player.play(AssetSource('sounds/$fileName'));
    } catch (e) {
      print("Error al reproducir audio: $e");
    }
  }
static Future<void> playExplosion() async {
  await _player.setVolume(1.0); // Volumen al máximo para el impacto
  await _player.play(AssetSource('sounds/explosion.mp3'));
}
  // Función para la alerta de emergencia (bucle o volumen alto)
  static Future<void> playEmergency() async {
    await _player.setVolume(1.0);
    await _player.play(AssetSource('sounds/emergency.mp3'));
  }
}