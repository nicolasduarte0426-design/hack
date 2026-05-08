class Nodo {
  final String nombre;
  final String mision;
  final double latitud;
  final double longitud;
  final String pregunta;   
  final String respuesta;    
  final List<String> pistas; 
  bool completado;            

  Nodo({
    required this.nombre,
    required this.mision,
    required this.latitud,
    required this.longitud,
    required this.pregunta,
    required this.respuesta,
    required this.pistas,
    this.completado = false,
  });
}