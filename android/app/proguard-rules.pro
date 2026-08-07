-keep class androidx.work.impl.** { *; }
-keep class * extends androidx.work.Worker
-keep class * extends androidx.work.InputMerger
-keep public class * extends androidx.work.ListenableWorker

-keep public class * implements com.google.firebase.components.ComponentRegistrar {
    public <init>();
}

# Google Sign-In / Play Services / Firebase Auth — R8 with no keep rules here
# was renaming com.google.android.gms.common.api.ApiException to a single
# letter (seen live as "com.google.android.gms.common.api.j" in a real
# device's exception text) and, more seriously, breaking the google_sign_in
# plugin's Pigeon-generated platform channel entirely — seen live as
# "PlatformException(channel-error, Unable to establish connection on
# channel: dev.flutter.pigeon.google_sign_in_android.GoogleSignInApi.signIn)".
# Not a guess: both came from an actual on-device diagnostic message.
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keep class io.flutter.plugins.googlesignin.** { *; }
-keep class dev.flutter.pigeon.** { *; }

# Sign in with Apple — same category of risk, no evidence yet of it being hit,
# but it shares the "native plugin behind a platform channel" shape that just
# broke for google_sign_in, so covering it preemptively rather than waiting
# for the same bug report under a different plugin.
-keep class com.aboutyou.dart_packages.sign_in_with_apple.** { *; }
