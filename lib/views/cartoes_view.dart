import 'dart:io';

import 'package:flutter/material.dart';

import '../controllers/cartao_controller.dart';
import '../controllers/categoria_controller.dart';
import '../controllers/sessao.dart';
import '../models/cartao.dart';
import '../widgets/widget_avisos.dart';
import '../widgets/widget_campo_texto.dart';
import '../widgets/widget_imagem_cartao.dart';
import '../widgets/widget_texto.dart';
import 'cartao_form_view.dart';


class CartoesView extends StatefulWidget {
  const CartoesView({super.key});

  @override
  State<CartoesView> createState() => _CartoesViewState();
}

class _CartoesViewState extends State<CartoesView> {
  final CartaoController _cartoesCtrl = CartaoController();
  final CategoriaController _categoriasCtrl = CategoriaController();
  List<Cartao> _cartoes = [];
  Map<int, String> _nomesCategorias = {};
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    final perfilId = Sessao.perfil!.id!;
    final cats = await _categoriasCtrl.listar(perfilId);
    final cartoes = await _cartoesCtrl.listarPorPerfil(perfilId);
    if (!mounted) return;
    setState(() {
      _nomesCategorias = {for (final c in cats) c.id!: c.nome};
      _cartoes = cartoes;
      _carregando = false;
    });
  }

  Future<void> _abrirFormulario([Cartao? cartao]) async {
    final alterou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => CartaoFormView(cartao: cartao)),
    );
    if (alterou == true) await _carregar();
  }

  Future<void> _alternarVisivel(Cartao cartao, bool visivel) async {
    await _cartoesCtrl.definirVisivel(cartao, visivel);
    await _carregar();
  }

  Future<void> _novaCategoria() async {
    final nome = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nova categoria'),
        content: CampoTexto(rotulo: 'Nome da categoria', controller: nome),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Criar'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    if (nome.text.trim().isEmpty) {
      Avisos.mostrar(context, 'Informe o nome da categoria.');
      return;
    }
    await _categoriasCtrl.criar(Sessao.perfil!.id!, nome.text);
    if (!mounted) return;
    Avisos.mostrar(context, 'Categoria criada.');
  }

  Widget _miniatura(Cartao c) {
    return SizedBox(
      width: 52,
      height: 52,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: c.ehEmoji
            ? ImagemCartao(c.imagemPath)
            : Image.file(
                File(c.imagemPath),
                fit: BoxFit.cover,
                errorBuilder: (context, erro, pilha) =>
                    const Icon(Icons.broken_image_outlined),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cartões'),
        actions: [
          IconButton(
            tooltip: 'Nova categoria',
            icon: const Icon(Icons.create_new_folder_outlined),
            onPressed: _novaCategoria,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Novo cartão'),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : _cartoes.isEmpty
              ? const Center(child: Textos('Nenhum cartão cadastrado.'))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
                  children: [
                    for (final c in _cartoes)
                      Card(
                        child: ListTile(
                          leading: _miniatura(c),
                          title: Text(c.rotulo),
                          subtitle: Text(
                            '${_nomesCategorias[c.categoriaId] ?? ''}\n"${c.fraseFalada}"',
                          ),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: c.visivel,
                                onChanged: (v) => _alternarVisivel(c, v),
                              ),
                              IconButton(
                                tooltip: 'Editar',
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () => _abrirFormulario(c),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}
