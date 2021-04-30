import 'package:dio/dio.dart';

Future<int?> uploadImage(
    {required String filename,
    required String filepath,
    required String url}) async {
  Dio dio = Dio();
  var formData = FormData.fromMap({
    'file': await MultipartFile.fromFile(filepath, filename: filename),
  });
  try {
    var response = await dio.post(url, data: formData);
    return response.statusCode;
  } on DioError catch (e) {
    if (e.response != null) {
      print(e.response!.statusMessage);
    } else {
      print(e.message);
    }

    return 0;
  }
}
