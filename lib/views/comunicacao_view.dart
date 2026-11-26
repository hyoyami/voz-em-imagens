import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/cartao_controller.dart';
import '../controllers/categoria_controller.dart';
import '../controllers/sessao.dart';
import '../controllers/toque_controller.dart';
import '../models/cartao.dart';
import '../models/categoria.dart';
import '../models/perfil.dart';
import '../services/voz_service.dart';
import '../utils/cores.dart';
import '../widgets/widget_barra_frase.dart';
import '../widgets/widget_cartao_comunicacao.dart';
import '../widgets/widget_texto.dart';
import 'painel_cuidador_view.dart';
import 'pin_dialog.dart';

/// MODO CRIANÇA: grade de cartões que falam ao toque (RF04, RF05, RF07, RF13).
/// A tela é travada: o botão voltar não funciona. A saída é pelo cadeado + PIN (RF11).
class ComunicacaoView extends StatefulWidget {
  const ComunicacaoView({super.key});

  @override
  State<ComunicacaoView> createState() => _ComunicacaoViewState();
}

class _ComunicacaoViewState extends State<ComunicacaoView> {
  final CategoriaController _categoriasCtrl = CategoriaController();
  final CartaoController _cartoesCtrl = CartaoController();
  final ToqueController _toques = ToqueController();
  final VozService _voz = VozService.instancia;

  List<Categoria> _categorias = []; // sem a categoria "Acesso rápido"
  Map<int, List<Cartao>> _porCategoria = {};
  Map<int, Color> _cores = {};
  List<Cartao> _acessoRapido = [];
  int? _categoriaAtual;
  final List<Cartao> _frase = [];
  bool _carregando = true;

  Perfil get _perfil => Sessao.perfil!;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final cats = await _categoriasCtrl.listar(_perfil.id!);
    final cartoes =
        await _cartoesCtrl.listarPorPerfil(_perfil.id!, apenasVisiveis: true);
    if (!mounted) return;

    final mapa = <int, List<Cartao>>{};
    for (final c in cartoes) {
      mapa.putIfAbsent(c.categoriaId, () => []).add(c);
    }

    final cores = <int, Color>{};
    final normais = <Categoria>[];
    int? idRapido;
    for (final cat in cats) {
      cores[cat.id!] = corDeHex(cat.cor);
      if (cat.nome == Categoria.nomeAcessoRapido) {
        idRapido = cat.id;
      } else {
        normais.add(cat);
      }
    }
    final listaRapida =
        idRapido == null ? <Cartao>[] : (mapa[idRapido] ?? <Cartao>[]);

    setState(() {
      _categorias = normais;
      _porCategoria = mapa;
      _cores = cores;
      _acessoRapido = listaRapida;
      final existe = normais.any((c) => c.id == _categoriaAtual);
      if (!existe) {
        _categoriaAtual = normais.isEmpty ? null : normais.first.id;
      }
      _carregando = false;
    });
  }

  Color _cor(int categoriaId) => _cores[categoriaId] ?? const Color(0xFF4DB6AC);

  /// Toque em um cartão comum. A voz sai primeiro e o registro no banco
  /// acontece em seguida, sem atrasar o som (meta de 300 ms, RNF08).
  void _aoTocar(Cartao cartao) {
    if (_perfil.config.modoFrase) {
      setState(() => _frase.add(cartao));
    } else {
      unawaited(_voz.falar(cartao.fraseFalada));
    }
    unawaited(_toques.registrar(perfilId: _perfil.id!, cartaoId: cartao.id!));
  }

  /// Cartões de acesso rápido (banheiro, dor, ajuda...) sempre falam na hora.
  void _aoTocarUrgente(Cartao cartao) {
    unawaited(_voz.falar(cartao.fraseFalada));
    unawaited(_toques.registrar(perfilId: _perfil.id!, cartaoId: cartao.id!));
  }

  void _falarFrase() {
    final texto = _frase.map((c) => c.fraseFalada).join('. ');
    unawaited(_voz.falar(texto));
  }

  Future<void> _abrirModoCuidador() async {
    final ok = await pedirPin(context);
    if (!ok || !mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PainelCuidadorView()),
    );
    if (!mounted) return;

    // Ao voltar, o cuidador pode ter mudado cartões ou configurações.
    _frase.clear();
    await _voz.definirVelocidade(_perfil.config.velocidade);
    await _carregar();
  }

  Widget _linhaAcessoRapido() {
    if (_acessoRapido.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 132,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: Row(
          children: [
            for (final c in _acessoRapido)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: CartaoComunicacao(
                    cartao: c,
                    cor: _cor(c.categoriaId),
                    compacto: true,
                    onTap: () => _aoTocarUrgente(c),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _linhaCategorias() {
    return SizedBox(
      height: 68,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        children: [
          for (final cat in _categorias)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(cat.nome, style: const TextStyle(fontSize: 18)),
                selected: cat.id == _categoriaAtual,
                onSelected: (_) => setState(() => _categoriaAtual = cat.id),
              ),
            ),
        ],
      ),
    );
  }

  Widget _grade() {
    final lista = _categoriaAtual == null
        ? <Cartao>[]
        : (_porCategoria[_categoriaAtual] ?? <Cartao>[]);

    if (lista.isEmpty) {
      return const Center(child: Textos('Nenhum cartão nesta categoria.'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _perfil.config.colunas,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.85,
      ),
      itemCount: lista.length,
      itemBuilder: (context, i) => CartaoComunicacao(
        cartao: lista[i],
        cor: _cor(lista[i].categoriaId),
        onTap: () => _aoTocar(lista[i]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // PopScope(canPop: false) bloqueia o botão voltar: a criança não sai do modo criança.
    return PopScope(
      canPop: false,
      // Voltar não sai do modo criança: pede o PIN (igual ao cadeado).
      onPopInvokedWithResult: (didPop, resultado) {
        if (!didPop) _abrirModoCuidador();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_perfil.nome),
          actions: [
            IconButton(
              tooltip: 'Modo cuidador',
              icon: const Icon(Icons.lock_outline),
              onPressed: _abrirModoCuidador,
            ),
          ],
        ),
        body: _carregando
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _linhaAcessoRapido(),
                  _linhaCategorias(),
                  Expanded(child: _grade()),
                  if (_perfil.config.modoFrase)
                    BarraFrase(
                      itens: _frase,
                      onFalar: _falarFrase,
                      onApagarUltimo: () =>
                          setState(() => _frase.removeLast()),
                      onLimpar: () => setState(() => _frase.clear()),
                    ),
                ],
              ),
      ),
    );
  }
}
