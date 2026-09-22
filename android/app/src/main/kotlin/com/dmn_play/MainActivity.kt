package com.dmn_play

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()
// package com.dmn_play

// import android.app.PictureInPictureParams
// import android.os.Build
// import android.util.Rational
// import io.flutter.embedding.android.FlutterActivity

// class MainActivity : FlutterActivity() {

//     private var allowPip = true

//     override fun onUserLeaveHint() {
//         super.onUserLeaveHint()

//         if (!allowPip) return

//         if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//             val params = PictureInPictureParams.Builder()
//                 .setAspectRatio(Rational(16, 9))
//                 .build()

//             enterPictureInPictureMode(params)
//         }
//     }

//     override fun onPictureInPictureModeChanged(
//     isInPictureInPictureMode: Boolean,
//     newConfig: Configuration
//     ) {
//         super.onPictureInPictureModeChanged(
//             isInPictureInPictureMode,
//             newConfig
//         )

//         if (isInPictureInPictureMode) {
//             channel.invokeMethod("pip_enter", null)
//         } else {
//             channel.invokeMethod("pip_exit", null)
//         }
//     }
// }