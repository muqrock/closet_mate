import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StorageService {
  static Future<File> saveImage(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final savedImage = await imageFile.copy('${directory.path}/$fileName.jpg');
    return savedImage;
  }
}