import 'package:http/http.dart' as http;

Future<int?> uploadImage(
    {required String filename,
    required String filepath,
    required String url}) async {
  var request = http.MultipartRequest('POST', Uri.parse(url));
  request.files.add(await http.MultipartFile.fromPath(filename, filepath));
  var res = await request.send();
  return res.statusCode;
}
