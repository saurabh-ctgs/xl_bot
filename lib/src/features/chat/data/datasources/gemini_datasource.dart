import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import '../../../../../flutter_sales_bot.dart';
import '../../../../core/constants/app_const.dart';

abstract class GeminiDataSource {
  Future<String> sendMessage(String message);
}

class GeminiDataSourceImpl implements GeminiDataSource {
  @override
  Future<String> sendMessage(String message) async {
    final url = AppConst.supabaseFunctionUrl;
    final bearer = AppConst.supabaseServiceRoleToken;
    try {
      final body = jsonEncode({
        'accessToken': SalesBotConfigManager.instance.config.projectId,
        'message': message,
      });

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $bearer',
        },
        body: body,
      );
      if (response.statusCode == 200) {

        try {
            return response.body;
        } catch (e) {
          developer.log('ℹ️ $e', name: 'FLUTTER_SALES_BOT');
          return response.body;
        }
      } else {
        if(response.statusCode == 503){
          return jsonEncode({

            "success": false,
            "message": jsonDecode(response.body)['message']??"The service is currently unavailable. Please try again later.",
          });


        }else if(response.statusCode == 401){
          developer.log(
            '❌ Status code : ${response.statusCode}',
            name: 'FLUTTER_SALES_BOT',
            error: response.body,
          );
          return jsonEncode({
            'success':false,
            'message':jsonDecode(response.body)['message']?? 'The service is currently unavailable. Please try again later.'
          });

        }else {
          developer.log(
            '❌ Status code : ${response.statusCode}',
            name: 'FLUTTER_SALES_BOT',
            error: response.body,
          );
          return jsonEncode({
            'success':false,
            'message': jsonDecode(response.body)['message']??'The service is currently unavailable. Please try again later.'
          });
        }
      }
    } catch (e, st) {
      developer.log(
        '❌ $e',
        name: 'FLUTTER_SALES_BOT',
      );
      return jsonEncode({
        'success':false,
        'message': 'The service is currently unavailable. Please try again later.'
      });
    }
  }
}
