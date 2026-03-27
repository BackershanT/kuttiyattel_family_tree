// Supabase Configuration
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  // Try to load from dart-define first (production), then fallback to dotenv (local)
  static String get supabaseUrl => 
      const String.fromEnvironment('SUPABASE_URL').isNotEmpty 
          ? const String.fromEnvironment('SUPABASE_URL') 
          : dotenv.env['SUPABASE_URL'] ?? '';

  static String get supabaseAnonKey => 
      const String.fromEnvironment('SUPABASE_ANON_KEY').isNotEmpty 
          ? const String.fromEnvironment('SUPABASE_ANON_KEY') 
          : dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  // Table names
  static const String personsTable = 'persons';
  static const String relationshipsTable = 'relationships';
}
