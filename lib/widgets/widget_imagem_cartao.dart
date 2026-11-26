import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../models/cartao.dart';


class ImagemCartao extends StatelessWidget {
  final String imagemPath;

  const ImagemCartao(this.imagemPath, {super.key});

  @override
  Widget build(BuildContext context) {
    if (imagemPath.startsWith(Cartao.prefixoEmoji)) {
      final emoji = imagemPath.substring(Cartao.prefixoEmoji.length);
      return FittedBox(
        fit: BoxFit.contain,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(emoji, style: const TextStyle(fontSize: 64)),
        ),
      );
    }
    // No navegador não há arquivos do aparelho; só os cartões de emoji aparecem.
    if (kIsWeb) {
      return const Center(child: Icon(Icons.image_not_supported_outlined));
    }
    return Image.file(
      File(imagemPath),
      fit: BoxFit.cover,
      errorBuilder: (context, erro, pilha) =>
          const Center(child: Icon(Icons.broken_image_outlined)),
    );
  }
}
