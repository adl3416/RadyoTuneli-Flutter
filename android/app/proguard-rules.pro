# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.** { *; }

# Play Core - Required for Flutter deferred components
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# Audio Service - Critical for media notifications
-keep class com.ryanheise.audioservice.** { *; }
-keep class com.ryanheise.audioservice.AudioService { *; }
-keep class com.ryanheise.audioservice.AudioServicePlugin { *; }
-keep class com.ryanheise.audioservice.AudioServiceActivity { *; }

# Just Audio
-keep class com.ryanheise.just_audio.** { *; }

# MediaSession and MediaBrowser
-keep class android.support.v4.media.** { *; }
-keep class androidx.media.** { *; }
-keep class android.media.** { *; }
-keep class androidx.media3.** { *; }

# ExoPlayer (used by just_audio)
-keep class com.google.android.exoplayer2.** { *; }
-keep class androidx.media3.exoplayer.** { *; }
-keep class androidx.media3.session.** { *; }
-keep class androidx.media3.common.** { *; }

# Keep notification classes
-keep class androidx.core.app.NotificationCompat** { *; }
-keep class androidx.core.app.NotificationManagerCompat { *; }

# Keep MediaBrowserService
-keep class android.service.media.MediaBrowserService { *; }
-keep class androidx.media.MediaBrowserServiceCompat { *; }

# Keep all Parcelable implementations
-keepclassmembers class * implements android.os.Parcelable {
    static ** CREATOR;
}

# Keep all Serializable implementations
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Android Auto
-keep class com.google.android.gms.car.** { *; }

# Keep R classes for resource access
-keepclassmembers class **.R$* {
    public static <fields>;
}

# Don't warn about missing classes
-dontwarn com.google.android.exoplayer2.**
-dontwarn androidx.media3.**
-dontwarn com.ryanheise.**
