package com.riva_psy.app

import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
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
    }
}
