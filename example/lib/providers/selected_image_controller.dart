import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_image_controller.g.dart';

@riverpod
class SelectedImageController extends _$SelectedImageController {
  @override
  FutureOr<String?> build() {
    return null;
  }

  Future<void> pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    state = AsyncData(image?.path);
  }
}
