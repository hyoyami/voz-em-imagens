import 'cartao.dart';

/// Períodos dos relatórios (RN05).
enum PeriodoRelatorio {
  semanal('Semanal'),
  mensal('Mensal'),
  anual('Anual');

  final String rotulo;
  const PeriodoRelatorio(this.rotulo);

  /// Semanal = últimos 7 dias, mensal = últimos 30 dias, anual = últimos 365 dias.
  DateTime inicio(DateTime agora) {
    switch (this) {
      case PeriodoRelatorio.semanal:
        return agora.subtract(const Duration(days: 7));
      case PeriodoRelatorio.mensal:
        return agora.subtract(const Duration(days: 30));
      case PeriodoRelatorio.anual:
        return agora.subtract(const Duration(days: 365));
    }
  }
}

class ItemRanking {
  final int cartaoId;
  final String rotulo;
  final String imagemPath;
  final int total;

  const ItemRanking({
    required this.cartaoId,
    required this.rotulo,
    required this.imagemPath,
    required this.total,
  });

  String get rotuloComIcone => imagemPath.startsWith(Cartao.prefixoEmoji)
      ? '${imagemPath.substring(Cartao.prefixoEmoji.length)} $rotulo'
      : rotulo;
}

class ItemCategoria {
  final String nome;
  final int total;

  const ItemCategoria({required this.nome, required this.total});
}

/// Resultado calculado a partir da tabela eventos_toque (não existe tabela de relatório).
class Relatorio {
  final PeriodoRelatorio periodo;
  final DateTime inicio;
  final int totalToques;
  final List<ItemRanking> ranking; // top 10
  final List<ItemCategoria> porCategoria;
  final List<int> porHora; // 24 posições (0h a 23h)

  const Relatorio({
    required this.periodo,
    required this.inicio,
    required this.totalToques,
    required this.ranking,
    required this.porCategoria,
    required this.porHora,
  });

  bool get vazio => totalToques == 0;

  int get maiorRanking => ranking.isEmpty ? 0 : ranking.first.total;

  int get maiorCategoria => porCategoria.isEmpty ? 0 : porCategoria.first.total;

  int get maiorHora =>
      porHora.isEmpty ? 0 : porHora.reduce((a, b) => a > b ? a : b);

  /// Horas com algum uso, em ordem crescente (para o gráfico).
  List<int> get horasComUso => [
        for (var h = 0; h < porHora.length; h++)
          if (porHora[h] > 0) h
      ];

  /// As 3 horas de maior uso (RF15).
  List<int> get horasDePico {
    final horas = horasComUso..sort((a, b) => porHora[b].compareTo(porHora[a]));
    return horas.take(3).toList();
  }
}
