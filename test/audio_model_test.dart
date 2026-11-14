import 'package:flutter_test/flutter_test.dart';
import 'package:riva_psy/core/models/audio/audio.dart';

void main() {
  test('Audio reads durations stored as numbers or as text', () {
    final a = Audio.fromJson({
      'fileName': 'x/y', 'name': 'n', 'tab': 't', 'format': 'mp3', 'folder': 'audio', 'emotions': '',
      'duration_ms': 431360, 'duration_ms_es': '524320', 'duration_ms_en': null,
      'fileName_es': 'es/x/y', 'name_es': 'ny',
    });
    expect(a.durationMs, 431360);
    expect(a.durationMsEs, 524320);
    expect(a.durationMsEn, isNull);
    expect(a.localizedFileName('es'), 'es/x/y');
    expect(a.localizedDuration('es'), const Duration(milliseconds: 524320));
  });
}
