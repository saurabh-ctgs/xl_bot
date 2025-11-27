import '../../features/chat/data/models/service_model.dart';

class AppConst {
  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
  static const String serviceBaseUrl = 'https://cityprofessionals.connivia.com';
  static const String token = 'demand_token';
  static const String searchServiceUri = '/api/v1/customer/service/search';

  static String supabaseFunctionUrl = 'https://twnvmbrenpkqdvovhmze.supabase.co/functions/v1/make-server-1fe93181/chat';

  static String supabaseServiceRoleToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR3bnZtYnJlbnBrcWR2b3ZobXplIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI5MzMzOTksImV4cCI6MjA3ODUwOTM5OX0.TljwiSBw7dl0C3jYk_3KwG04YaDP7Kbx8zM-EH-j1ow';

}