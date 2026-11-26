/// Formatações simples de data e hora (sem depender do pacote intl).
class Formatador {
  static String dataCurta(DateTime d) =>
      '${_dois(d.day)}/${_dois(d.month)}/${d.year}';

  static String hora(int h) => '${_dois(h)}h';

  static String _dois(int n) => n.toString().padLeft(2, '0');
}
