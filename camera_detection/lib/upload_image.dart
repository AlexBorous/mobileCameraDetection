import 'package:dio/dio.dart';

Future<String?> uploadImage(
    {required String filename,
    required String filepath,
    required String url}) async {
  Dio dio = Dio();
  var formData = FormData.fromMap({
    'file': await MultipartFile.fromFile(filepath, filename: filename),
  });
  try {
    await dio.post(url, data: formData);
    return "good";
  } on DioError catch (e) {
    if (e.response != null) {
      return (e.response!.statusMessage);
    } else {
      return (e.message);
    }
  }
}
