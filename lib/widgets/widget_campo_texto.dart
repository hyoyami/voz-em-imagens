import 'package:flutter/material.dart';


class CampoTexto extends StatelessWidget {
  final String rotulo;
  final TextEditingController? controller;
  final String? dica;
  final bool obscuro;
  final TextInputType? teclado;
  final int? maxLength;

  const CampoTexto({
    super.key,
    required this.rotulo,
    this.controller,
    this.dica,
    this.obscuro = false,
    this.teclado,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscuro,
      keyboardType: teclado,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: rotulo,
        hintText: dica,
        counterText: '',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
