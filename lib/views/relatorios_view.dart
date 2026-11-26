import 'package:flutter/material.dart';

import '../controllers/relatorio_controller.dart';
import '../controllers/sessao.dart';
import '../models/relatorio.dart';
import '../utils/formatador.dart';
import '../widgets/widget_barra_relatorio.dart';
import '../widgets/widget_botao.dart';
import '../widgets/widget_texto.dart';

/// Relatórios semanal, mensal e anual (RF09, RF10, RF15).
class RelatoriosView extends StatefulWidget {
  const RelatoriosView({super.key});

  @override
  State<RelatoriosView> createState() => _RelatoriosViewState();
}

class _RelatoriosViewState extends State<RelatoriosView> {
  final RelatorioController _ctrl = RelatorioController();
  PeriodoRelatorio _periodo = PeriodoRelatorio.semanal;
  Relatorio? _relatorio;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() => _carregando = true);
    final r = await _ctrl.gerar(
      perfilId: Sessao.perfil!.id!,
      periodo: _periodo,
    );
    if (!mounted) return;
    setState(() {
      _relatorio = r;
      _carregando = false;
    });
  }

  void _trocarPeriodo(PeriodoRelatorio p) {
    setState(() => _periodo = p);
    _carregar();
  }

  Widget _titulo(String texto) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 6),
        child: Textos(texto, tamanho: 18, negrito: true),
      );

  List<Widget> _conteudo(Relatorio r) {
    if (r.vazio) {
      return const [
        SizedBox(height: 32),
        Textos(
          'Nenhum toque registrado neste período.',
          alinhamento: TextAlign.center,
        ),
      ];
    }

    final picos = r.horasDePico.map(Formatador.hora).join(', ');

    return [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Textos(
            '${r.totalToques} toques desde ${Formatador.dataCurta(r.inicio)}',
            tamanho: 18,
            negrito: true,
          ),
        ),
      ),
      _titulo('Cartões mais usados'),
      for (final item in r.ranking)
        BarraRelatorio(
          rotulo: item.rotuloComIcone,
          valor: item.total,
          maximo: r.maiorRanking,
        ),
      _titulo('Uso por categoria'),
      for (final item in r.porCategoria)
        BarraRelatorio(
          rotulo: item.nome,
          valor: item.total,
          maximo: r.maiorCategoria,
          cor: Theme.of(context).colorScheme.tertiary,
        ),
      _titulo('Horários de pico'),
      Textos('Maior uso por volta de: $picos'),
      const SizedBox(height: 8),
      for (final h in r.horasComUso)
        BarraRelatorio(
          rotulo: Formatador.hora(h),
          valor: r.porHora[h],
          maximo: r.maiorHora,
          cor: Theme.of(context).colorScheme.secondary,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final relatorio = _relatorio;
    return Scaffold(
      appBar: AppBar(title: Text('Relatório de ${Sessao.perfil!.nome}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              for (final p in PeriodoRelatorio.values)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Botoes(
                      p.rotulo,
                      destaque: p == _periodo,
                      onPressed: () => _trocarPeriodo(p),
                    ),
                  ),
                ),
            ],
          ),
          if (_carregando || relatorio == null)
            const Padding(
              padding: EdgeInsets.only(top: 48),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            ..._conteudo(relatorio),
          const SizedBox(height: 24),
          const Textos(
            'Os relatórios mostram apenas dados de uso do aplicativo e não '
            'são diagnóstico nem avaliação clínica. Leve-os ao profissional '
            'que acompanha a criança.',
            tamanho: 12,
          ),
        ],
      ),
    );
  }
}
