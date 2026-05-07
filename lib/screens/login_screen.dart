import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

import '../services/auth_service.dart';
import '../widgets/terminal_text.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService authService = AuthService();

  int failedAttempts = 0;
  bool blocked = false;

  String statusText = 'INICIANDO SHADOWNET...';

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      authenticate();
    });
  }

  Future<void> authenticate() async {
    if (blocked) return;

    setState(() {
      statusText = 'ESCANEO BIOMETRICO REQUERIDO';
    });

    bool authenticated = await authService.authenticate();

    if (authenticated) {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    } else {
      failedAttempts++;

      if (failedAttempts >= 3) {
        setState(() {
          blocked = true;
          statusText = 'PROTOCOLO DE AUTODESTRUCCION INICIADO';
        });

        if (await Vibration.hasVibrator() ?? false) {
          Vibration.vibrate(duration: 5000);
        }

        await Future.delayed(const Duration(seconds: 5));

        setState(() {
          failedAttempts = 0;
          blocked = false;
          statusText = 'SISTEMA REINICIADO';
        });
      } else {
        setState(() {
          statusText =
              'ACCESO DENEGADO | INTENTO $failedAttempts DE 3';
        });
      }
    }
  }

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
            children: [
              const Icon(
                Icons.lock,
                color: Color(0xFF00FF00),
                size: 100,
              ),

              const SizedBox(height: 30),

              const TerminalText(
                text: 'SHADOWNET TERMINAL',
                size: 32,
              ),

              const SizedBox(height: 20),

              const TerminalText(
                text: 'Objetivo: Hackear receta Coca-Cola',
                size: 18,
              ),

              const SizedBox(height: 40),

              TerminalText(
                text: statusText,
                size: 20,
                color: statusText.contains('AUTODESTRUCCION')
                    ? Colors.red
                    : const Color(0xFF00FF00),
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: blocked ? null : authenticate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  side: const BorderSide(
                    color: Color(0xFF00FF00),
                    width: 2,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                ),
                child: const TerminalText(
                  text: 'ESCANEAR HUELLA',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}