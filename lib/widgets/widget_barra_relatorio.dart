import 'package:flutter/material.dart';


class BarraRelatorio extends StatelessWidget {
  final String rotulo;
  final int valor;
  final int maximo;
  final Color? cor;

  const BarraRelatorio({
    super.key,
    required this.rotulo,
    required this.valor,
    required this.maximo,
    this.cor,
  });

  @override
  Widget build(BuildContext context) {
    final corBarra = cor ?? Theme.of(context).colorScheme.primary;
    final fracao = maximo <= 0 ? 0.0 : (valor / maximo).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 112,
            child: Text(rotulo, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: fracao,
                child: Container(
                  height: 18,
                  decoration: BoxDecoration(
                    color: corBarra,
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              '$valor',
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
