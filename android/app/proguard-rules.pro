## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication

## Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.firebase.remoteconfig.** { *; }
-keep class com.google.firebase.crashlytics.** { *; }
-keep class com.google.firebase.messaging.** { *; }
-keep class com.google.firebase.analytics.** { *; }
-keep class com.google.firebase.auth.** { *; }
-keep class com.google.firebase.firestore.** { *; }
-keep class com.google.firebase.database.** { *; }
-keep class com.google.firebase.storage.** { *; }
-keep class com.google.firebase.appcheck.** { *; }
-keep class com.google.firebase.installations.** { *; }

## Play Services
-keep class com.google.android.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.gms.**

## Prevent obfuscation of JSON library used by Firebase
-keep class com.fasterxml.jackson.** { *; }
-keep class com.google.gson.** { *; }

## Ensure classes with native methods are not stripped
-keepclasseswithmembers class * {
    native <methods>;
}

-keepclasseswithmembernames class * {
    native <methods>;
}

-keepclassmembers class com.simonwork.models.** {
  *;
}

-keepclassmembers class com.simonwork.dnpp.models.** {
  *;
}

-keepclassmembers class com.simonwork.dnpp.dnpp.models.** {
  *;
}

-keepattributes Signature

## Retrofit (if used)
-keep class retrofit2.** { *; }
-dontwarn retrofit2.**
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**

## Keep annotations for libraries like Room, Retrofit, etc.
-keepattributes *Annotation*

-keep class com.google.android.gms.internal.** { *; }