-keep class androidx.work.impl.** { *; }
-keep class * extends androidx.work.Worker
-keep class * extends androidx.work.InputMerger
-keep public class * extends androidx.work.ListenableWorker

-keep public class * implements com.google.firebase.components.ComponentRegistrar {
    public <init>();
}
