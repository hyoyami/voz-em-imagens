import 'package:flutter/material.dart';

import '../models/cartao.dart';
import 'widget_botao.dart';
import 'widget_texto.dart';


class BarraFrase extends StatelessWidget {
  final List<Cartao> itens;
  final VoidCallback onFalar;
  final VoidCallback onApagarUltimo;
  final VoidCallback onLimpar;

  const BarraFrase({
    super.key,
    required this.itens,
    required this.onFalar,
    required this.onApagarUltimo,
    required this.onLimpar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 52,
            child: itens.isEmpty
                ? const Center(
                    child: Textos('Toque nos cartões para montar uma frase'),
                  )
                : ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final c in itens)
                        Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Chip(label: Text(c.rotuloComIcone)),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Botoes(
                  'Falar',
                  icone: Icons.volume_up,
                  onPressed: itens.isEmpty ? null : onFalar,
                ),
              ),
              IconButton(
                tooltip: 'Apagar o último',
                icon: const Icon(Icons.backspace_outlined),
                onPressed: itens.isEmpty ? null : onApagarUltimo,
              ),
              IconButton(
                tooltip: 'Limpar a frase',
                icon: const Icon(Icons.delete_outline),
                onPressed: itens.isEmpty ? null : onLimpar,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
