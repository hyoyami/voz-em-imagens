import 'package:flutter/material.dart';

import '../controllers/perfil_controller.dart';
import '../controllers/sessao.dart';
import '../models/config_voz.dart';
import '../services/voz_service.dart';
import '../widgets/widget_avisos.dart';
import '../widgets/widget_botao.dart';
import '../widgets/widget_texto.dart';

/// Voz, velocidade, colunas da grade e modo frase do perfil (RF17).
class ConfiguracoesView extends StatefulWidget {
  const ConfiguracoesView({super.key});

  @override
  State<ConfiguracoesView> createState() => _ConfiguracoesViewState();
}

class _ConfiguracoesViewState extends State<ConfiguracoesView> {
  final PerfilController _ctrl = PerfilController();
  late ConfigVoz _config;

  @override
  void initState() {
    super.initState();
    _config = Sessao.perfil!.config;
  }

  Future<void> _testarVoz() async {
    final voz = VozService.instancia;
    // Procura a voz pt-BR de novo (útil logo depois de instalar a voz no aparelho).
    final achou = await voz.iniciar();
    if (!mounted) return;
    if (!achou) {
      Avisos.mostrar(
        context,
        'Não encontrei voz em português do Brasil neste aparelho. Instale em '
        'Configurações do Android → Idioma → Saída de texto para voz.',
      );
      return;
    }
    await voz.definirVelocidade(_config.velocidade);
    await voz.falar('Olá! Esta é a minha voz em português do Brasil.');
  }

  Future<void> _salvar() async {
    final perfil = Sessao.perfil!.copyWith(config: _config);
    await _ctrl.salvarConfig(perfil);
    Sessao.perfil = perfil;
    await VozService.instancia.definirVelocidade(_config.velocidade);
    if (!mounted) return;
    Avisos.mostrar(context, 'Configurações salvas.');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Configurações de ${Sessao.perfil!.nome}')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Textos('Velocidade da voz', negrito: true, tamanho: 18),
          Slider(
            value: _config.velocidade,
            min: 0.2,
            max: 1.0,
            divisions: 8,
            label: _config.velocidade.toStringAsFixed(1),
            onChanged: (v) => setState(() => _config = _config.copyWith(velocidade: v)),
          ),
          Botoes('Testar voz', icone: Icons.volume_up, destaque: false, onPressed: _testarVoz),
          const SizedBox(height: 24),
          const Textos('Cartões por linha', negrito: true, tamanho: 18),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final n in [2, 3, 4])
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Botoes(
                      '$n',
                      destaque: _config.colunas == n,
                      onPressed: () =>
                          setState(() => _config = _config.copyWith(colunas: n)),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Modo frase'),
            subtitle: const Text(
              'Os toques montam uma frase na barra e só falam ao tocar em "Falar". '
              'Os cartões de acesso rápido sempre falam na hora.',
            ),
            value: _config.modoFrase,
            onChanged: (v) =>
                setState(() => _config = _config.copyWith(modoFrase: v)),
          ),
          const SizedBox(height: 24),
          Botoes('Salvar', icone: Icons.check, onPressed: _salvar),
        ],
      ),
    );
  }
}
