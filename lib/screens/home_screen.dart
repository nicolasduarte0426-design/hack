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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              TerminalText(
                text: 'ACCESS GRANTED',
                size: 32,
              ),
              SizedBox(height: 30),
              TerminalText(
                text: 'OBJETIVO:',
                size: 22,
              ),
              SizedBox(height: 10),
              TerminalText(
                text: 'Hackear formula secreta Coca-Cola',
                size: 20,
              ),
              SizedBox(height: 30),
              TerminalText(
                text: 'Conectando a servidores...',
                size: 18,
              ),
              SizedBox(height: 10),
              TerminalText(
                text: 'Bypass de seguridad iniciado...',
                size: 18,
              ),
              SizedBox(height: 10),
              TerminalText(
                text: 'ShadowNet conectado.',
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}