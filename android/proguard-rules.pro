#Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.plugin.editing.** { *; }

#Crashlytics
-keepattributes SourceFile,LineNumberTable        # Keep file names and line numbers.
-keep public class * extends java.lang.Exception  
-keep class com.example_app.** { *; }.   # Unique App id

#twilio_programmable_video 
-keep class tvi.webrtc.** { *; }
-keep class com.twilio.video.** { *; }
-keep class com.twilio.common.** { *; }

# Flutter-specific rules
-keepattributes *Annotation*
-keepclassmembers class **.R$* {
    public static <fields>;
}
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet);
}
-keepclassmembers class * extends androidx.lifecycle.ViewModel {
    <fields>;
    <methods>;
}

# Bloc-specific rules
-keepclassmembers class ** {
    @dart: entry-point *;
}