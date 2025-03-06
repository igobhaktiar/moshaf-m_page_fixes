import 'dart:convert';
import 'dart:io';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:qeraat_moshaf_kwait/injection_container.dart' as di;

import '../error/exceptions.dart';
import 'app_interceptors.dart';
import 'end_points.dart';
import 'status_code.dart';

class DioConsumer {
  final Dio client;

  DioConsumer({required this.client}) {
    (client.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      return client;
    };
    String currentBaseUrl =
        EndPoints.getBaseUrlAccordingToBuildTarget(di.getItInstance());
    client.options
      ..baseUrl = currentBaseUrl
      ..responseType = ResponseType.plain
      ..validateStatus = (status) {
        return status! < StatusCode.internalServerError;
      };

    client.httpClientAdapter = IOHttpClientAdapter()
      ..onHttpClientCreate = (client) => client..maxConnectionsPerHost = 3;

    client.interceptors.add(di.getItInstance<AppIntercepters>());
    if (kDebugMode) {
      client.interceptors.add(di.getItInstance<LogInterceptor>());
    }
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    (client.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
        (HttpClient dioClient) {
      dioClient.badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);
      return dioClient;
    };
    return await client.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path,
      {Map<String, dynamic>? body,
      bool formDataIsEnabled = false,
      Map<String, dynamic>? queryParameters}) async {
    return await client.post(path,
        queryParameters: queryParameters,
        data: formDataIsEnabled ? FormData.fromMap(body!) : body);
  }

  Future<Response> download({
    required String remoteUrl,
    required String storagePath,
    void Function(int, int)? onRecieveProgress,
  }) async {
    try {
      return await client.download(remoteUrl, storagePath,
          onReceiveProgress: onRecieveProgress, deleteOnError: true);
    } catch (e) {
      debugPrint(e.toString());
      if (File(storagePath).existsSync()) {
        File(storagePath).deleteSync();
        log("salem deleted file $storagePath");
        return Response(requestOptions: RequestOptions());
      }
    }
    return Response(requestOptions: RequestOptions());
  }

  Future put(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response =
          await client.put(path, queryParameters: queryParameters, data: body);
      return _handleResponseAsJson(response);
    } on DioException catch (error) {
      _handleDioError(error);
    }
  }

  Future head(
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response =
          await client.head(path, queryParameters: queryParameters, data: body);
      return response;
    } on DioException catch (error) {
      _handleDioError(error);
    }
  }

  dynamic _handleResponseAsJson(Response<dynamic> response) {
    final responseJson = jsonDecode(response.data.toString());
    return responseJson;
  }

  dynamic _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw const FetchDataException();
      case DioExceptionType.badResponse:
        switch (error.response?.statusCode) {
          case StatusCode.badRequest:
            throw const BadRequestException();
          case StatusCode.unauthorized:
          case StatusCode.forbidden:
            throw const UnauthorizedException();
          case StatusCode.notFound:
            throw const NotFoundException();
          case StatusCode.confilct:
            throw const ConflictException();

          case StatusCode.internalServerError:
            throw const InternalServerErrorException();
        }
        break;
      case DioExceptionType.cancel:
        break;
      case DioExceptionType.unknown:
        throw const NoInternetConnectionException();
      case DioExceptionType.connectionTimeout:
      // TODO: Handle this case.
      case DioExceptionType.badCertificate:
      // TODO: Handle this case.
    }
  }
}
