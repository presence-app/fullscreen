import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui';
import 'package:flutter/services.dart';

class FullScreen {
  // Initialize method channel
  static const MethodChannel _channel = const MethodChannel('fullscreen');

  /// To enable fullscreen mode, pass the fullscreen mode as an argument the the enterFullScreen method of the FullScreen class.
  static Future<void> enterFullScreen(FullScreenMode fullScreenMode) async {
    if (Platform.isIOS) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    } else if (Platform.isAndroid) {
      try {
        if (fullScreenMode == FullScreenMode.EMERSIVE) {
          await _channel.invokeMethod('emersive');
        } else if (fullScreenMode == FullScreenMode.EMERSIVE_STICKY) {
          await _channel.invokeMethod('emersiveSticky');
        } else if (fullScreenMode == FullScreenMode.LEANBACK) {
          await _channel.invokeMethod('leanBack');
        }
      } catch (e) {
        print(e);
      }
    }
  }

  /// to get the current status of the SystemUI
  static Future<bool> get isFullScreen async {
    double? nativeHeight;

    final physicalSize = PlatformDispatcher.instance.views.first.physicalSize;
    // Default value for flutter app is 44
    // https://medium.com/flutter-community/a-flutter-guide-to-visual-overlap-padding-viewpadding-and-viewinsets-a63e214be6e8
    final flutterDefaultViewPaddingTop = 44;
    // Default value for flutetr app is 44
    //final flutterDefaultViewPaddingBottom= 34;

    // Add ViewPaddingTop coz the top bar is not hidden by system
    // when user hides the buttons inside the system navbar
    double dartHeight = physicalSize.height + flutterDefaultViewPaddingTop ;

    try {
      nativeHeight = await _channel.invokeMethod("getHeight");
    } catch (e) {
      print(e);
    }
    //debugPrint('FlutterScreen: nativeHeight $nativeHeight');
    //debugPrint('FlutterScreen: dartHeight $dartHeight');

    // It is fullscreen mode if difference between two sizes is < 25px
    if((nativeHeight != null && (nativeHeight - dartHeight).abs() < 25)) {
      return true;
    } else {
      return false;
    }
  }

  /// Exit full screen
  static Future<void> exitFullScreen() async {
    if (Platform.isIOS) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    } else if (Platform.isAndroid) {
      try {
        await _channel.invokeMethod('exitFullScreen');
      } catch (e) {
        print(e);
      }
    }
  }
}

enum FullScreenMode { EMERSIVE, EMERSIVE_STICKY, LEANBACK }
