// Supabase Configuration
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  // Load from environment variables (.env file)
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  static String get supabaseSecretKey => dotenv.env['SUPABASE_SECRET_KEY'] ?? '';
  
  // Table names
  static const String personsTable = 'persons';
  static const String relationshipsTable = 'relationships';
}
