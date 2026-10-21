package com.riva_psy.app

import android.content.Intent
import android.os.Bundle
import androidx.core.view.WindowCompat
import com.ryanheise.audioservice.AudioServiceFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// AudioServiceFragmentActivity (not plain FlutterActivity/FlutterFragmentActivity)
// — required by audio_service (which just_audio_background depends on).
// It's not just about being a FragmentActivity: this specific subclass
// (provided by audio_service itself) routes provideFlutterEngine() through
// AudioServicePlugin.getFlutterEngine() so the Activity shares the exact
// FlutterEngine instance the background audio service manages. Using plain
// FlutterFragmentActivity still throws "The Activity class declared in your
// AndroidManifest.xml is wrong..." on every AppAudioService.play() call,
// since audio_service's engine-identity check (AudioServicePlugin.java,
// onAttachedToActivity) specifically checks `instanceof AudioServiceFragmentActivity`,
// not just FragmentActivity-ness. Drop-in compatible with FlutterActivity
// for everything else this app uses (it's a FlutterFragmentActivity itself).
class MainActivity: AudioServiceFragmentActivity() {
    // Android 15 (API 35+) makes edge-to-edge the default; without this the
    // Play Console "unsupported edge-to-edge APIs" advisory flags the app.
    // WindowCompat.setDecorFitsSystemWindows works on any Activity subclass
    // (unlike the Jetpack enableEdgeToEdge() extension, which requires
    // ComponentActivity — FlutterActivity doesn't extend that). Existing
    // screens already use SafeArea, so content stays clear of the system
    // bars regardless of this setting.
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        WindowCompat.setDecorFitsSystemWindows(window, false)
        pendingQuickAction = intent?.getStringExtra("quick_action")
    }

    // App-icon shortcut ("Хочется написать или проверить"): the extra is kept
    // until Dart asks for it once ("take"), so it works from a cold start and
    // when the app is already open.
    private var pendingQuickAction: String? = null

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        intent.getStringExtra("quick_action")?.let { pendingQuickAction = it }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "riva/quick").setMethodCallHandler { call, result ->
            if (call.method == "take") {
                result.success(pendingQuickAction)
                pendingQuickAction = null
            } else {
                result.notImplemented()
            }
        }
    }
}
