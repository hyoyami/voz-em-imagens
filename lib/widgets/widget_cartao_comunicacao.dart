import 'package:flutter/material.dart';

import '../models/cartao.dart';
import 'widget_imagem_cartao.dart';


class CartaoComunicacao extends StatefulWidget {
  final Cartao cartao;
  final Color cor;
  final VoidCallback onTap;
  final bool compacto;

  const CartaoComunicacao({
    super.key,
    required this.cartao,
    required this.cor,
    required this.onTap,
    this.compacto = false,
  });

  @override
  State<CartaoComunicacao> createState() => _CartaoComunicacaoState();
}

class _CartaoComunicacaoState extends State<CartaoComunicacao> {
  bool _pressionado = false;

  void _definirPressionado(bool valor) {
    if (_pressionado != valor) {
      setState(() => _pressionado = valor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressionado ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 120),
      child: Material(
        color: widget.cor.withAlpha(40),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: widget.cor, width: 2),
        ),
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) => _definirPressionado(true),
          onTapUp: (_) => _definirPressionado(false),
          onTapCancel: () => _definirPressionado(false),
          child: Column(
            children: [
              Expanded(child: ImagemCartao(widget.cartao.imagemPath)),
              Padding(
                padding: EdgeInsets.fromLTRB(4, 0, 4, widget.compacto ? 6 : 12),
                child: Text(
                  widget.cartao.rotulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: widget.compacto ? 15 : 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
