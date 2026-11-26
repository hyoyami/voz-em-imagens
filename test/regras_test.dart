import 'package:flutter_test/flutter_test.dart';
import 'package:voz_em_imagens/models/cartao.dart';
import 'package:voz_em_imagens/models/config_voz.dart';
import 'package:voz_em_imagens/models/relatorio.dart';
import 'package:voz_em_imagens/utils/seguranca.dart';

void main() {
  group('Seguranca (RNF06)', () {
    test('não guarda a senha em texto simples', () {
      final hash = Seguranca.hashSenha('a@b.com', 'segredo123');
      expect(hash, isNot(contains('segredo123')));
      expect(hash.length, 64);
    });

    test('mesmos dados geram o mesmo hash; e-mail diferente muda o hash', () {
      expect(Seguranca.hashPin('a@b.com', '1234'),
          Seguranca.hashPin('A@B.com ', '1234'));
      expect(Seguranca.hashPin('a@b.com', '1234'),
          isNot(Seguranca.hashPin('c@d.com', '1234')));
    });
  });

  group('Períodos do relatório (RN05)', () {
    final agora = DateTime.utc(2026, 11, 8, 10);

    test('semanal, mensal e anual', () {
      expect(PeriodoRelatorio.semanal.inicio(agora), DateTime.utc(2026, 11, 1, 10));
      expect(PeriodoRelatorio.mensal.inicio(agora), DateTime.utc(2026, 10, 9, 10));
      expect(PeriodoRelatorio.anual.inicio(agora), DateTime.utc(2025, 11, 8, 10));
    });
  });

  group('Relatorio', () {
    test('horas de pico em ordem decrescente de uso', () {
      final porHora = List<int>.filled(24, 0);
      porHora[9] = 2;
      porHora[14] = 5;
      porHora[20] = 7;
      final r = Relatorio(
        periodo: PeriodoRelatorio.semanal,
        inicio: DateTime(2026, 11, 1),
        totalToques: 14,
        ranking: const [],
        porCategoria: const [],
        porHora: porHora,
      );
      expect(r.horasDePico, [20, 14, 9]);
      expect(r.maiorHora, 7);
    });
  });

  group('Cartao e ConfigVoz', () {
    test('reconhece cartão de emoji', () {
      const c = Cartao(
        categoriaId: 1,
        rotulo: 'Xixi',
        fraseFalada: 'Preciso fazer xixi',
        imagemPath: 'emoji:🚽',
      );
      expect(c.ehEmoji, isTrue);
      expect(c.emoji, '🚽');
    });

    test('ConfigVoz vai e volta em JSON', () {
      const original = ConfigVoz(velocidade: 0.7, colunas: 4, modoFrase: true);
      final lida = ConfigVoz.fromJson(original.toJson());
      expect(lida.velocidade, 0.7);
      expect(lida.colunas, 4);
      expect(lida.modoFrase, isTrue);
      expect(ConfigVoz.fromJson('lixo').colunas, 2);
    });
  });
}
