

import 'dart:convert';

import 'package:flutter/widgets.dart';





Image imageFromString(String input, {double? width, double? height, BoxFit? fit = BoxFit.cover, }) {
  return Image.memory(base64Decode(input), width: width, height: height,fit:fit,);
}

