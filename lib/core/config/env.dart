import 'package:envied/envied.dart';

part 'env.g.dart';

// Для DEV середовища
@Envied(path: '.env.dev', name: 'EnvDev')
abstract class EnvDev {
  @EnviedField(varName: 'SUPABASE_URL', obfuscate: true)
  static final String supabaseUrl = _EnvDev.supabaseUrl;

  @EnviedField(varName: 'SUPABASE_KEY', obfuscate: true)
  static final String supabaseKey = _EnvDev.supabaseKey;

  @EnviedField(varName: 'SENTRY_DSN', obfuscate: true)
  static final String sentryDsn = _EnvDev.sentryDsn;
  
  @EnviedField(varName: 'APP_TITLE')
  static const String appTitle = _EnvDev.appTitle;
}

// Для PROD середовища
@Envied(path: '.env.prod', name: 'EnvProd')
abstract class EnvProd {
  @EnviedField(varName: 'SUPABASE_URL', obfuscate: true)
  static final String supabaseUrl = _EnvProd.supabaseUrl;

  @EnviedField(varName: 'SUPABASE_KEY', obfuscate: true)
  static final String supabaseKey = _EnvProd.supabaseKey;

  @EnviedField(varName: 'SENTRY_DSN', obfuscate: true)
  static final String sentryDsn = _EnvProd.sentryDsn;
  
  @EnviedField(varName: 'APP_TITLE')
  static const String appTitle = _EnvProd.appTitle;
}