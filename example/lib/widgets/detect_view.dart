import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ultralytics_yolo/ultralytics_yolo.dart';
import 'package:ultralytics_yolo_example/providers/object_detector.dart';
import 'package:ultralytics_yolo_example/providers/prediction_mode_controller.dart';
import 'package:ultralytics_yolo_example/providers/selected_image_controller.dart';
import 'package:ultralytics_yolo_example/utils.dart';
import 'package:ultralytics_yolo_example/widgets/time_and_fps.dart';

class DetectView extends ConsumerWidget {
  const DetectView(
    this._cameraController, {
    super.key,
  });

  final UltralyticsYoloCameraController _cameraController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(objectDetectorProvider).when(
          data: (objectDetector) =>
              switch (ref.watch(predictionModeControllerProvider)) {
            PredictionMode.camera => Stack(
                children: [
                  UltralyticsYoloCameraPreview(
                    predictor: objectDetector,
                    controller: _cameraController,
                    onCameraCreated: () {},
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: TimeAndFps(
                      inferenceTimeStream: objectDetector.inferenceTime,
                      fpsRateStream: objectDetector.fpsRate,
                    ),
                  )
                ],
              ),
            PredictionMode.gallery => ref
                .watch(selectedImageControllerProvider)
                .when(
                  data: (path) => path != null
                      ? FutureBuilder<List<DetectedObject?>?>(
                          future: objectDetector.detect(
                            imagePath: path,
                          ),
                          builder: (context, snapshot) {
                            final detectionList = snapshot.data;

                            return Stack(
                              children: [
                                Center(
                                  child: Image.file(
                                    File(path),
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting)
                                  const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                else if (detectionList is List<DetectedObject>)
                                  CustomPaint(
                                    painter: ObjectDetectorPainter(
                                      detectionList,
                                    ),
                                  ),
                              ],
                            );
                          })
                      : TextButton(
                          onPressed: ref
                              .read(selectedImageControllerProvider.notifier)
                              .pickImage,
                          child: const Text('Select image'),
                        ),
                  error: (error, stackTrace) => const Text('No image'),
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
          },
          error: (error, stackTrace) =>
              const Center(child: Text('No detection model')),
          loading: () => const Center(child: CircularProgressIndicator()),
        );
  }
}
