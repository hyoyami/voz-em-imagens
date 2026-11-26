import 'package:flutter/material.dart';


class Textos extends StatelessWidget {
  final String texto;
  final double? tamanho;
  final bool negrito;
  final Color? cor;
  final TextAlign alinhamento;

  const Textos(
    this.texto, {
    super.key,
    this.tamanho,
    this.negrito = false,
    this.cor,
    this.alinhamento = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      textAlign: alinhamento,
      style: TextStyle(
        fontSize: tamanho,
        fontWeight: negrito ? FontWeight.bold : FontWeight.normal,
        color: cor,
      ),
    );
  }
}
