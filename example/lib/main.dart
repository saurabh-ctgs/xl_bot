import 'package:flutter/material.dart';
import 'package:flutter_sales_bot/flutter_sales_bot.dart';

void main() {
  // Initialize SalesBotConfig once at app startup
  final config = SalesBotConfig(
    projectId: 'fltai_y9-VOYfSbPAUyhrNx3qI-tdipGA2SZ6x',
    searchApis: [
      SearchApi(name: 'Service provider', searchUrl: 'https://cityprofessionals.connivia.com/api/v1/customer/service/search'),
      SearchApi(name: 'Blood test', searchUrl: 'https://911.connivia.com/api/patient/v2/fetch-all-packages')
    ],
    defaultTimeout: const Duration(seconds: 8),
  );

  // Initialize the config manager globally
  SalesBotConfigManager.initialize(config);

  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Sales Bot Example')),
        body: const Center(child: Text('Tap the chat button')),
        floatingActionButton: SalesBotButton(
          icon: const Icon(Icons.support_agent, size: 28),
          useGradient: true,
          size: 64,
          tooltip: 'Get Support',
          uiConfig: ChatUIConfig.light(

          ).copyWith(
            onTapDefaultActionButton: (value) {
              // Handle action button tap
              debugPrint('Action button tapped: $value');
            },
          ),

          actionButtons: [
            ActionButton(
              widget: Container(color: Colors.red,height: 20,width: double.maxFinite,),
              onTap: ( value) {
                print( 'Action 1 tapped with value: $value');
              },
            ),
            ActionButton(
                widget: const Icon(Icons.help_outline, size: 24, color: Colors.white),
                onTap: ( value) {
                  print( 'Action 2 tapped with value: $value');
                }

            ),
            ActionButton(
                widget: const Icon(Icons.help_outline, size: 24, color: Colors.white),
                onTap: ( value) {
                  print( 'Action 2 tapped with value: $value');
                }

            ),
          ],
        ),
      ),
    );
  }
}
