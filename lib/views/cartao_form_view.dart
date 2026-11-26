import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/cartao_controller.dart';
import '../controllers/categoria_controller.dart';
import '../controllers/sessao.dart';
import '../models/cartao.dart';
import '../models/categoria.dart';
import '../widgets/widget_avisos.dart';
import '../widgets/widget_botao.dart';
import '../widgets/widget_campo_texto.dart';
import '../widgets/widget_texto.dart';


class CartaoFormView extends StatefulWidget {
  final Cartao? cartao;

  const CartaoFormView({super.key, this.cartao});

  @override
  State<CartaoFormView> createState() => _CartaoFormViewState();
}

class _CartaoFormViewState extends State<CartaoFormView> {
  final CartaoController _cartoesCtrl = CartaoController();
  final CategoriaController _categoriasCtrl = CategoriaController();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _rotulo = TextEditingController();
  final TextEditingController _frase = TextEditingController();
  final TextEditingController _emoji = TextEditingController();

  List<Categoria> _categorias = [];
  int? _categoriaId;
  String? _fotoPath; // caminho da foto, se houver
  bool _salvando = false;

  bool get _editando => widget.cartao != null;

  @override
  void initState() {
    super.initState();
    final c = widget.cartao;
    if (c != null) {
      _rotulo.text = c.rotulo;
      _frase.text = c.fraseFalada;
      _categoriaId = c.categoriaId;
      if (c.ehEmoji) {
        _emoji.text = c.emoji;
      } else {
        _fotoPath = c.imagemPath;
      }
    }
    _carregarCategorias();
  }

  @override
  void dispose() {
    _rotulo.dispose();
    _frase.dispose();
    _emoji.dispose();
    super.dispose();
  }

  Future<void> _carregarCategorias() async {
    final lista = await _categoriasCtrl.listar(Sessao.perfil!.id!);
    if (!mounted) return;
    setState(() {
      _categorias = lista;
      _categoriaId ??= lista.isEmpty ? null : lista.first.id;
    });
  }

  Future<void> _escolherFoto(ImageSource origem) async {
    try {
      final arquivo = await _picker.pickImage(
        source: origem,
        maxWidth: 800,
        imageQuality: 80,
      );
      if (arquivo == null) return;
      final caminho = await _cartoesCtrl.copiarImagem(arquivo.path);
      if (!mounted) return;
      setState(() => _fotoPath = caminho);
    } catch (e) {
      if (!mounted) return;
      Avisos.mostrar(context, 'Não foi possível abrir a câmera ou a galeria.');
    }
  }

  Future<void> _salvar() async {
    final rotulo = _rotulo.text.trim();
    final frase = _frase.text.trim();
    if (rotulo.isEmpty || frase.isEmpty) {
      Avisos.mostrar(context, 'Preencha o nome e a frase falada.');
      return;
    }
    if (_categoriaId == null) {
      Avisos.mostrar(context, 'Escolha uma categoria.');
      return;
    }

    // Foto tem prioridade; sem foto usa o emoji; sem nenhum dos dois, um "?".
    final emoji = _emoji.text.trim().isEmpty ? '❓' : _emoji.text.trim();
    final imagem = _fotoPath ?? '${Cartao.prefixoEmoji}$emoji';

    setState(() => _salvando = true);
    final antigo = widget.cartao;
    await _cartoesCtrl.salvar(Cartao(
      id: antigo?.id,
      categoriaId: _categoriaId!,
      rotulo: rotulo,
      fraseFalada: frase,
      imagemPath: imagem,
      audioPath: antigo?.audioPath,
      ordem: antigo?.ordem ?? 0,
      visivel: antigo?.visivel ?? true,
    ));
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _excluir() async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir cartão?'),
        content: const Text(
          'Se o cartão já foi usado, ele será apenas ocultado para manter o '
          'histórico dos relatórios.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
    if (confirmou != true) return;

    final excluiu = await _cartoesCtrl.excluirOuOcultar(widget.cartao!);
    if (!mounted) return;
    Avisos.mostrar(
      context,
      excluiu ? 'Cartão excluído.' : 'Cartão já usado: foi apenas ocultado.',
    );
    Navigator.pop(context, true);
  }

  Widget _previa() {
    final Widget conteudo;
    if (_fotoPath != null) {
      conteudo = Image.file(
        File(_fotoPath!),
        fit: BoxFit.cover,
        errorBuilder: (context, erro, pilha) =>
            const Icon(Icons.broken_image_outlined),
      );
    } else {
      final emoji = _emoji.text.trim().isEmpty ? '❓' : _emoji.text.trim();
      conteudo = FittedBox(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(emoji, style: const TextStyle(fontSize: 64)),
        ),
      );
    }
    return Center(
      child: SizedBox(
        width: 140,
        height: 140,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ColoredBox(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: conteudo,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_editando ? 'Editar cartão' : 'Novo cartão')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _previa(),
            const SizedBox(height: 16),
            if (kIsWeb)
              const Textos(
                'Fotos só funcionam no celular. No navegador, use um emoji.',
                tamanho: 13,
              )
            else
            Row(
              children: [
                Expanded(
                  child: Botoes(
                    'Câmera',
                    icone: Icons.photo_camera,
                    destaque: false,
                    onPressed: () => _escolherFoto(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Botoes(
                    'Galeria',
                    icone: Icons.photo_library,
                    destaque: false,
                    onPressed: () => _escolherFoto(ImageSource.gallery),
                  ),
                ),
              ],
            ),
            if (_fotoPath != null)
              TextButton(
                onPressed: () => setState(() => _fotoPath = null),
                child: const Text('Remover foto e usar emoji'),
              ),
            const SizedBox(height: 16),
            CampoTexto(
              rotulo: 'Emoji (usado se não houver foto)',
              controller: _emoji,
              maxLength: 4,
            ),
            const SizedBox(height: 16),
            CampoTexto(rotulo: 'Nome do cartão (ex.: Xixi)', controller: _rotulo),
            const SizedBox(height: 16),
            CampoTexto(
              rotulo: 'Frase falada (ex.: Preciso fazer xixi)',
              controller: _frase,
            ),
            const SizedBox(height: 16),
            const Textos('Categoria', negrito: true),
            DropdownButton<int>(
              isExpanded: true,
              value: _categoriaId,
              items: [
                for (final cat in _categorias)
                  DropdownMenuItem<int>(value: cat.id, child: Text(cat.nome)),
              ],
              onChanged: (v) => setState(() => _categoriaId = v),
            ),
            const SizedBox(height: 24),
            Botoes(
              _salvando ? 'Salvando...' : 'Salvar',
              icone: Icons.check,
              onPressed: _salvando ? null : _salvar,
            ),
            if (_editando) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _excluir,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Excluir cartão'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
