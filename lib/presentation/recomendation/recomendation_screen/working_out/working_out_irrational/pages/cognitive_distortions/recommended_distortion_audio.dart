import 'package:shared_preferences/shared_preferences.dart';

const _r2AudioBaseUrl = 'https://pub-cd14ca249f1e4d4fbfb07ca99a7efe6d.r2.dev/audio/';

// A handful of distortions have a direct, specific link to one of the
// Guided Journals pilot tracks — surfaced inline on the distortion's own
// card (see CognitiveDistortionsPage), not just inside the Guided Journal
// exercise itself. Only catastrophizing has one so far; add more keys here
// as those connections get made.
const Map<String, Map<String, String>> _recommendedAudioPaths = {
  'catastrophizing': {
    'ru': 'fear2/vozvrat_v_seychas',
    'en': 'en/fear/Return_to_the_present',
    'es': 'es/miedo/Regresar_al_presente',
  },
};

class RecommendedDistortionAudio {
  static bool hasRecommendation(String distortionKey) =>
      _recommendedAudioPaths.containsKey(distortionKey);

  static Future<String?> urlFor(String distortionKey) async {
    final paths = _recommendedAudioPaths[distortionKey];
    if (paths == null) return null;
    final prefs = await SharedPreferences.getInstance();
    final langCode = (prefs.getString('locale') ?? 'ru_RU').split('_').first;
    final path = paths[langCode] ?? paths['ru']!;
    return Uri.encodeFull(_r2AudioBaseUrl + path + '.mp3');
  }
}
