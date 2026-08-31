import 'package:shared_preferences/shared_preferences.dart';

// Same R2 base + no-extension-in-storage / append-.mp3-in-code convention as
// RecommendedDistortionAudio. Paths verified two ways before landing here:
// read back from the live Firestore `Audio` docs (source of truth, not the
// pre-upload write-script guess that seeded them) AND independently HEAD/
// Range-checked against the actual R2 objects — 6 of 7 EN and 6 of 7 ES
// paths had wrong casing (e.g. "Removing_Armor" guessed vs the real
// "Removing_armor") until this fix; see PROJECT_CONTEXT.md §62/§63.
const _r2AudioBaseUrl = 'https://pub-cd14ca249f1e4d4fbfb07ca99a7efe6d.r2.dev/audio/';

const Map<String, Map<String, String>> _portraitTrackPaths = {
  'removing_armor': {
    'ru': 'introduction/snyatie_broni',
    'en': 'en/introduction/Removing_armor',
    'es': 'es/introduccion/Quitar_la_armadura',
  },
  'right_to_pause': {
    'ru': 'laziness/pravo_na_pauzu',
    'en': 'en/laziness/Right_to_pause',
    'es': 'es/pereza/Derecho_a_hacer_una_pausa',
  },
  'reactor_cooling': {
    'ru': 'wrath/ohlazhdenie_reaktora',
    'en': 'en/anger/Reactor_cooling',
    'es': 'es/ira/Refrigeracion_del_reactor',
  },
  'contour_restoration': {
    'ru': 'uncertainty/vosstanovlenie_kontura',
    'en': 'en/uncertainty/Contour_restoration',
    'es': 'es/inseguridad/Restauracion_de_contornos',
  },
  'dropping_charges': {
    'ru': 'guilt/snyatie_obvineniy',
    'en': 'en/guilt/Dropping_the_charges',
    'es': 'es/culpa/Retirar_los_cargos',
  },
  'return_to_present': {
    'ru': 'fear2/vozvrat_v_seychas',
    'en': 'en/fear/Return_to_the_present',
    'es': 'es/miedo/Regresar_al_presente',
  },
  'cache_reset': {
    'ru': 'lostness/sbros_kesha',
    'en': 'en/lostness/Clear_cache',
    'es': 'es/perdida/Borrar_cache',
  },
};

class PortraitAudioTracks {
  static Future<String?> urlFor(String trackId) async {
    final paths = _portraitTrackPaths[trackId];
    if (paths == null) return null;
    final prefs = await SharedPreferences.getInstance();
    final langCode = (prefs.getString('locale') ?? 'ru_RU').split('_').first;
    final path = paths[langCode] ?? paths['ru']!;
    return Uri.encodeFull(_r2AudioBaseUrl + path + '.mp3');
  }
}
