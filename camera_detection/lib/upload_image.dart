import 'package:http/http.dart' as http;

Future<int?> uploadImage(
    {required String filename,
    required String filepath,
    required String url}) async {
  var uri;

  try {
    uri = Uri.parse(url);
  } on FormatException catch (e) {
    print(e.toString());
    return 0;
  }
  var request = http.MultipartRequest('POST', uri);
  request.files.add(await http.MultipartFile.fromPath(filename, filepath));
  var res = await request.send();
  return res.statusCode;
}
