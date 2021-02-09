import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' show basename, join;
import 'package:dio/dio.dart';

Future <Response> Upload(File imagePath) async {
  var imageStream = imagePath.openRead();
  //open read reads a file and sends imgapath as type Stream<List<int>>
  //later used in MultiPartFile call
  //since imagePath is of type future <int> hence it is of synchronous nature
  //this warants an await and an async
  var length = await imagePath.length();
  var uri = "http://192.168.0.6:5000/";
  Dio  dio = new Dio();
  var response = await dio.post(uri,
    data: imageStream,
    options: Options(
        headers: {
          Headers.contentLengthHeader: length,
        }
    ),
  );
  return response;
}

Future<Response> sendform(
    String url, Map<String, dynamic> data, Map<String, File> imagefile
    ) async { //async method since Multipart uses file.length() which is an async method that warrants await
  for(MapEntry entry in data.entries){
    File file = entry.value;
    String name = basename(file.path);
    imagefile[entry.key] = MultipartFile(file.openRead(), await file.length(), filename: name) as File;
  }
  data.addAll(imagefile);
  var formdata = FormData.fromMap(data);
  Dio dio = new Dio();
  return await dio.post(url,
    data: formdata,
    options: Options(contentType: 'multipart/form-data'),
  );
}