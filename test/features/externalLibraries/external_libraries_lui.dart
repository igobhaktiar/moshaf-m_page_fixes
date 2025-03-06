import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qeraat_moshaf_kwait/core/api/dio_consumer.dart';
import 'package:qeraat_moshaf_kwait/core/api/end_points.dart';
import 'package:qeraat_moshaf_kwait/injection_container.dart';

void main() {
  group('External libraries Logic test', () {
    test('External Library test statusCode endpoint', () async {
      await init();
      final response = await (DioConsumer(client: Dio())
          .get("${EndPoints.baseUrl}/${EndPoints.externalResources}"));
      expect(response.statusCode, 200);
    });

    test('External Library test statusCode endpoint', () async {
      await init();
      final response = await (DioConsumer(client: Dio())
          .get("${EndPoints.baseUrl}/${EndPoints.externalResources}"));
      expect(response.statusCode, 200);
    });
  });
}
