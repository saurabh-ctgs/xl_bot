import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../config.dart';
import '../../../../core/constants/app_const.dart';
import '../models/service_model.dart';

abstract class ServiceDataSource {
  Future<List<ProductItemModel>> searchServices(String query, {int limit = 10, int offset = 1});
}

class ServiceDataSourceImpl implements ServiceDataSource {
  final SalesBotConfig config;
  ServiceDataSourceImpl({required this.config});

  @override
  Future<List<ProductItemModel>> searchServices(String query, {int limit = 10, int offset = 1}) async {

    Map<String, dynamic> data = {
      "string": query,
    };

    try {
      // Build URL with limit and offset parameters
      final searchUrl = config.searchApis[1].buildSearchUrl(query:query, limit: limit, offset: offset);

      final response = await http.get(
        Uri.parse(searchUrl),
        // body: jsonEncode(data),
        headers: {
          'Authorization': 'Bearer ${AppConst.token}',
          'Content-Type': 'application/json',
          'zoneId': 'cafb63dc-4ff6-4037-8bf2-80996a05d967',
        },
      );

      if (response.statusCode == 200) {
        print(response.body);

        if(config.searchApis[1].searchUrl.contains('cityprofessionals')){

        final data = mapServiceJsonToProductResponse(jsonDecode(response.body));
        return data.products ?? [];
        }
        else{
          final data= ProductResponseModel.fromJson(jsonDecode(response.body));
          return data.products ?? [];
        }
      } else {
        throw Exception('Failed to search services: ${response.statusCode}');
      }
    } catch (e, st) {
      print(e);
      print(st);
      throw Exception('Error searching services: $e');
    }
  }
}