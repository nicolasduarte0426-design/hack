import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TerminalText extends StatelessWidget {
  final String text;
  final double size;
  final Color color;

  const TerminalText({
    super.key,
    required this.text,
    this.size = 18,
    this.color = const Color(0xFF00FF00),
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.robotoMono(
        color: color,
        fontSize: size,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}