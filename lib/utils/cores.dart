import 'package:flutter/material.dart';

/// Converte um texto "#RRGGBB" em [Color]. Se for inválido, devolve [padrao].
Color corDeHex(String? hex, [Color padrao = const Color(0xFF4DB6AC)]) {
  if (hex == null) return padrao;
  final limpo = hex.replaceAll('#', '');
  final valor = int.tryParse(limpo, radix: 16);
  if (valor == null || limpo.length != 6) return padrao;
  return Color(0xFF000000 | valor);
}
