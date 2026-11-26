import 'dart:developer' as developer;

import 'package:flutter_tts/flutter_tts.dart';


class VozService {
  VozService._();

  static final VozService instancia = VozService._();

  static const String _engineGoogle = 'com.google.android.tts';

  final FlutterTts _tts = FlutterTts();


  bool ptBrDisponivel = false;

  Future<bool> iniciar() async {
    try {
      await _escolherEngineGoogle();
      await _tts.setLanguage('pt-BR');
      ptBrDisponivel = await _escolherVozPtBr();
      await _tts.setSpeechRate(0.5);
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
      // Fila "flush": a nova fala substitui a anterior direto no motor de voz,
      // sem uma chamada stop() separada antes (era isso que atrasava o som).
      await _tts.setQueueMode(0);
      // Não espera a fala terminar para devolver o controle ao app.
      await _tts.awaitSpeakCompletion(false);
    } catch (e) {
      developer.log('Falha ao iniciar a voz: $e', name: 'VozService');
      ptBrDisponivel = false;
    }
    if (!ptBrDisponivel) {
      developer.log('Nenhuma voz pt-BR encontrada.', name: 'VozService');
    }
    return ptBrDisponivel;
  }

  Future<void> _escolherEngineGoogle() async {
    try {
      final engines = await _tts.getEngines;
      if (engines is List && engines.contains(_engineGoogle)) {
        await _tts.setEngine(_engineGoogle);
      }
    } catch (e) {
      developer.log('Sem escolha de engine: $e', name: 'VozService');
    }
  }


  Future<bool> _escolherVozPtBr() async {
    final vozes = await _tts.getVoices;
    if (vozes is! List) return false;

    Map? escolhida;
    for (final v in vozes) {
      if (v is! Map) continue;
      final idioma =
      (v['locale'] ?? '').toString().replaceAll('_', '-').toLowerCase();
      if (idioma != 'pt-br') continue;
      escolhida ??= v;
      if ((v['name'] ?? '').toString().contains('local')) {
        escolhida = v;
        break;
      }
    }
    if (escolhida == null) return false;

    await _tts.setVoice({
      'name': escolhida['name'].toString(),
      'locale': escolhida['locale'].toString(),
    });
    return true;
  }

  Future<void> definirVelocidade(double velocidade) async {
    try {
      await _tts.setSpeechRate(velocidade);
    } catch (e) {
      developer.log('Falha ao ajustar a velocidade: $e', name: 'VozService');
    }
  }

  Future<void> falar(String texto) async {
    if (texto.trim().isEmpty) return;
    try {
      await _tts.speak(texto);
    } catch (e) {
      developer.log('Falha ao falar: $e', name: 'VozService');
    }
  }

  Future<void> parar() async {
    try {
      await _tts.stop();
    } catch (e) {
      developer.log('Falha ao parar a voz: $e', name: 'VozService');
    }
  }
}