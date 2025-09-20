# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

# Keep MainActivity
-keep class com.sih.qrail.MainActivity { *; }

# Keep Flutter classes
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep all classes that extend FlutterActivity
-keep class * extends io.flutter.embedding.android.FlutterActivity { *; }

# Don't warn about missing classes
-dontwarn io.flutter.**