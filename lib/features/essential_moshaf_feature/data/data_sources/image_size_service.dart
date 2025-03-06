import 'dart:ui' as ui;

import 'package:flutter/services.dart';

Future<Size> getPngLogicalSize(String assetPath) async {
  print(assetPath);
  ByteData data = await rootBundle.load(assetPath);
  Uint8List bytes = data.buffer.asUint8List();

  // Decode the image using instantiateImageCodec
  final ui.Codec codec = await ui.instantiateImageCodec(bytes);
  final ui.FrameInfo frame = await codec.getNextFrame();

  // Get the raw dimensions of the image
  double rawWidth = frame.image.width.toDouble();
  double rawHeight = frame.image.height.toDouble();

  // Adjust for device pixel ratio
  double devicePixelRatio = ui.window.devicePixelRatio;
  double logicalWidth = rawWidth / devicePixelRatio;
  double logicalHeight = rawHeight / devicePixelRatio;
  print(
      "logicalWidth: $logicalWidth , logicalHeight:$logicalHeight $assetPath");

  return Size(logicalWidth, logicalHeight);
}

Future<Size> getPngActualSize(String assetPath) async {
  // Load the image bytes
  ByteData data = await rootBundle.load(assetPath);
  Uint8List bytes = data.buffer.asUint8List();

  // Decode the image using instantiateImageCodec
  final ui.Codec codec = await ui.instantiateImageCodec(bytes);
  final ui.FrameInfo frame = await codec.getNextFrame();

  // Get the actual dimensions of the image
  double rawWidth = frame.image.width.toDouble();
  double rawHeight = frame.image.height.toDouble();

  // Return the actual size (raw pixel dimensions)
  return Size(rawWidth, rawHeight);
}
