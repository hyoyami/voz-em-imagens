import 'package:flutter/material.dart';


class Botoes extends StatelessWidget {
  final String texto;
  final VoidCallback? onPressed;
  final IconData? icone;
  final bool destaque;

  const Botoes(
    this.texto, {
    super.key,
    required this.onPressed,
    this.icone,
    this.destaque = true,
  });

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;
    final estilo = ElevatedButton.styleFrom(
      backgroundColor: destaque ? cores.primary : cores.surfaceContainerHighest,
      foregroundColor: destaque ? cores.onPrimary : cores.onSurface,
      minimumSize: const Size(0, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );

    if (icone == null) {
      return ElevatedButton(
        onPressed: onPressed,
        style: estilo,
        child: Text(texto),
      );
    }
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: estilo,
      icon: Icon(icone),
      label: Text(texto),
    );
  }
}
