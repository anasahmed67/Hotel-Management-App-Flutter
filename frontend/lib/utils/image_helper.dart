import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Widget showImage(String path) {
  if (kIsWeb) {
    return Image.network(
      path,
      fit: BoxFit.cover,
    );
  } else {
    return Image.file(
      File(path),
      fit: BoxFit.cover,
    );
  }
}