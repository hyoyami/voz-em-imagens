import '../database/app_database.dart';
import '../models/evento_toque.dart';

/// Registra cada toque em um cartão (RF08, RN01).
class ToqueController {
  // Guarda o último toque para ignorar toques acidentais repetidos (RN07).
  static int? _ultimoCartao;
  static DateTime? _ultimoMomento;

  static const Duration _intervaloMinimo = Duration(seconds: 1);

  /// Devolve true se o toque foi registrado e false se foi ignorado (RN07).
  Future<bool> registrar({
    required int perfilId,
    required int cartaoId,
  }) async {
    final agora = DateTime.now();

    final repetido = _ultimoCartao == cartaoId &&
        _ultimoMomento != null &&
        agora.difference(_ultimoMomento!) < _intervaloMinimo;
    if (repetido) return false;

    _ultimoCartao = cartaoId;
    _ultimoMomento = agora;

    final db = await AppDatabase.instancia.database;
    await db.insert(
      'eventos_toque',
      EventoToque(perfilId: perfilId, cartaoId: cartaoId, dataHora: agora)
          .toMap(),
    );
    return true;
  }
}
