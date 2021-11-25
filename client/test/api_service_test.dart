import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:music_room/src/data/service/api_service.dart';
import 'package:music_room/src/data/service/firebase_service.dart';

void main() {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'http://172.31.232.174:3000',
      connectTimeout: 5000,
      receiveTimeout: 3000,
    ),
  );
  final dioAdapter = DioAdapter(dio: dio);

  dio.httpClientAdapter = dioAdapter;

  // dioAdapter.onGet(path).reply(200, {'message': 'Successfully mocked GET!'});

  final ApiService apiService = ApiService(dio);
  // setUp(() => {
  //       dioAdapter.onPost('http://172.31.232.174:3000/users/forgetPassword',
  //           (server) {
  //         server.reply(201, {});
  //       })
  //     });

  group('forgetPasswordCode', () {
    const path = '/users/forgetPassword';
    test('should return normally', () async {
      dioAdapter.onPost(path, (server) {
        server.reply(200, {});
      }, data: {"email": "dimitrihauet@gmail.com"});

      expect(
          () async =>
              await apiService.forgetPasswordCode("dimitrihauet@gmail.com"),
          returnsNormally);
    });

    test('should return normally', () async {
      dioAdapter.onPost(path, (server) {
        server.reply(422, {"message": "too bad"});
      }, data: {"email": "dimitrihauet@gmail.com"});
      expect(
          () async =>
              await apiService.forgetPasswordCode("dimitrihauet@gmail.com"),
          throwsA(isA<ApiServerError>()));
    });
  });
  group('forgetPasswordUpdate', () {
    const code = '1nhjaskd';
    const path = '/users/forgetPassword/$code';
    test('should throw an error', () async {
      dioAdapter.onPost(path, (server) {
        server.reply(200, {});
      }, data: {"email": "dimitrihauet@gmail.com", "password": "ZAazerty59@"});

      expect(
          () async => await apiService.forgetPasswordUpdate(
              "dimitrihauet@gmail.com", "ZAazerty59@", code),
          returnsNormally);
    });

    test('should throw an error', () async {
      dioAdapter.onPost(path, (server) {
        server.reply(422, {"message": "too bad"});
      }, data: {"email": "dimitrihauet@gmail.com", "password": "ZAazerty59@"});
      expect(
          () async => await apiService.forgetPasswordUpdate(
              "dimitrihauet@gmail.com", "ZAazerty59@", code),
          throwsA(isA<ApiServerError>()));
    });
  });
}
