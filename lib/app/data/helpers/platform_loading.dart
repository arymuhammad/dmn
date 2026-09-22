import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget platformLoading() {
  return Platform.isAndroid
      ? CircularProgressIndicator(
        color: Colors.amber,
        // value:
        //     indicatorController!.state.isLoading
        //         ? null
        //         : math.min(indicatorController.value, 1.0),
      )
      : const CupertinoActivityIndicator();
}
