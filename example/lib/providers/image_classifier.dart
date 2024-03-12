import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:ultralytics_yolo/predict/classify/image_classifier.dart'
    as classifier;
import 'package:ultralytics_yolo/yolo_model.dart';

part 'image_classifier.g.dart';

@riverpod
class ImageClassifier extends _$ImageClassifier {
  @override
  FutureOr<classifier.ImageClassifier> build() {
    return _initImageClassifierWithLocalModel();
  }

  Future<classifier.ImageClassifier>
      _initImageClassifierWithLocalModel() async {
    if (Platform.isIOS) {
      final modelPath = await _copy('assets/yolov8n-cls.mlmodel');
      final model = LocalYoloModel(
        id: '',
        task: Task.classify,
        format: Format.coreml,
        modelPath: modelPath,
      );

      final imageClassifier = classifier.ImageClassifier(model: model);

      await imageClassifier.loadModel();

      return imageClassifier;
    } else if (Platform.isAndroid) {
      final modelPath = await _copy('assets/yolov8n-cls_int8.tflite');
      final metadataPath = await _copy('assets/metadata-cls.yaml');
      final model = LocalYoloModel(
        id: '',
        task: Task.classify,
        format: Format.tflite,
        modelPath: modelPath,
        metadataPath: metadataPath,
      );

      final imageClassifier = classifier.ImageClassifier(model: model);

      await imageClassifier.loadModel();

      return imageClassifier;
    } else {
      throw Exception('Platform not supported');
    }
  }

  Future<String> _copy(String assetPath) async {
    final path = '${(await getApplicationSupportDirectory()).path}/$assetPath';
    await Directory(dirname(path)).create(recursive: true);
    final file = File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(assetPath);
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
    return file.path;
  }
}
