# Flutter ProGuard rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Supabase
-keepattributes Signature
-keepattributes *Annotation*
-keep class io.supabase.** { *; }
-keep class com.google.gson.** { *; }
-keep class sun.misc.Unsafe { *; }

# Google Sign-In
-keep class com.google.android.gms.** { *; }
-keep class com.google.android.gms.auth.** { *; }
-dontwarn com.google.android.gms.**

# RevenueCat
-keep class com.revenuecat.purchases.** { *; }

# Sign in with Apple
-keep class com.aboutyou.dart_packages.sign_in_with_apple.** { *; }

# General Android
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep custom application class
-keep public class * extends android.app.Application

# Play Core Library (for split APKs)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

# Keep Parcelables
-keepclassmembers class * implements android.os.Parcelable {
    static ** CREATOR;
}

# Kotlin Coroutines
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}
-keepclassmembernames class kotlinx.** {
    volatile <fields>;
}