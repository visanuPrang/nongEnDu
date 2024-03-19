import 'package:flutter/material.dart';

class MyDateUtil {
// for getting formatted time from milliSeconds SinceEpochs String
  static String getFormattedTime(
      {required BuildContext context, required String time}) {
    // final date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final date = DateTime.fromMillisecondsSinceEpoch(1640979000000);
    debugPrint('$date');
    debugPrint(TimeOfDay.fromDateTime(date).format(context));
    return TimeOfDay.fromDateTime(date).format(context);
  }
}
