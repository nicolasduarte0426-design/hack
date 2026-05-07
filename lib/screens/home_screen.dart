import 'package:flutter/material.dart';
import '../widgets/terminal_text.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [

              SizedBox(height: 80),

              Center(
                child: Icon(
                  Icons.lock_open,
                  color: Color(0xFF00FF00),
                  size: 120,
                ),
              ),

              SizedBox(height: 30),

              Center(
                child: TerminalText(
                  text: 'ACCESS GRANTED',
                  size: 34,
                ),
              ),

              SizedBox(height: 50),

              TerminalText(
                text: 'Conectando a servidores Coca-Cola...',
                size: 18,
              ),

              SizedBox(height: 15),

              TerminalText(
                text: 'Bypass de firewall completado...',
                size: 18,
              ),

              SizedBox(height: 15),

              TerminalText(
                text: 'Descargando archivos clasificados...',
                size: 18,
              ),

              SizedBox(height: 40),

              TerminalText(
                text: '========== RECETA CLASIFICADA ==========',
                size: 20,
              ),

              SizedBox(height: 30),

              TerminalText(
                text: 'Azucar Refinada: 70%',
                size: 18,
              ),

              SizedBox(height: 10),

              TerminalText(
                text: 'Extracto de Vainilla: 12%',
                size: 18,
              ),

              SizedBox(height: 10),

              TerminalText(
                text: 'Aceites Citricos Secretos: 8%',
                size: 18,
              ),

              SizedBox(height: 10),

              TerminalText(
                text: 'Cafeina: 3%',
                size: 18,
              ),

              SizedBox(height: 10),

              TerminalText(
                text: 'Componente X-13: CLASIFICADO',
                size: 18,
              ),

              SizedBox(height: 40),

              TerminalText(
                text: 'ShadowNet conectado correctamente.',
                size: 18,
              ),

              SizedBox(height: 20),

              TerminalText(
                text: 'Estado del sistema: ESTABLE',
                size: 18,
              ),

              SizedBox(height: 20),

              TerminalText(
                text: 'Nivel de acceso: ROOT',
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}