#####################################
# Flutter
#####################################

-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

#####################################
# Kotlin
#####################################

-keep class kotlin.** { *; }

#####################################
# Gson
#####################################

-keepattributes Signature
-keepattributes *Annotation*

-keep class com.google.gson.** { *; }

#####################################
# JWT
#####################################

-keep class com.auth0.** { *; }
-keep class io.jsonwebtoken.** { *; }

#####################################
# Google Sign In
#####################################

-keep class com.google.android.gms.** { *; }

#####################################
# Firebase
#####################################

-keep class com.google.firebase.** { *; }

#####################################
# HLS / Exoplayer
#####################################

-keep class androidx.media3.** { *; }
-keep class com.google.android.exoplayer2.** { *; }

#####################################
# Retrofit
#####################################

-keep class retrofit2.** { *; }

#####################################
# OkHttp
#####################################

-keep class okhttp3.** { *; }

#####################################
# Annotation
#####################################

-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**