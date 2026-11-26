import '../models/cuidador.dart';
import '../models/perfil.dart';

/// Guarda em memória quem está usando o app agora.
class Sessao {
  static Cuidador? cuidador;
  static Perfil? perfil;

  static void limpar() {
    cuidador = null;
    perfil = null;
  }
}
