import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

showToast(message) {
  Fluttertoast.showToast(
    msg: message,
    // backgroundColor: Colors.grey[700],
    textColor: Colors.white,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    webBgColor: ' #979B999',
    timeInSecForIosWeb: 2,
    webPosition: 'center',
  );
}