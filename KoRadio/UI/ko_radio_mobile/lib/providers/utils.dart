

import 'dart:convert';

import 'package:flutter/widgets.dart';





Image imageFromString(String input) {
  return Image.memory(base64Decode(input));
}

