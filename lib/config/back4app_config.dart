// Back4App configuration. This supports loading values from a .env file
// (using flutter_dotenv) or from secure storage at runtime. Provide your
// credentials outside of source control.
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Back4AppConfig {
  // These are mutable so they can be initialized at startup using env or secure storage
  static String baseUrl = '';
  static String appId = '';
  static String restApiKey = '';

  // App version used in left panel
  static const String appVersion = 'v1.0';

  /// Call this at app startup to load configuration.
  /// Priority: .env values (BACK4APP_*), then secure storage values.
  static Future<void> init() async {
    // Try loading .env if present
    var _dotenvLoaded = false;
    try {
      await dotenv.load();
      _dotenvLoaded = true;
    } catch (_) {
      _dotenvLoaded = false;
    }

    if (_dotenvLoaded) {
      // Only access dotenv.env if loading succeeded; on web the .env asset may
      // not exist and dotenv throws a NotInitializedError when accessed.
      baseUrl = dotenv.env['BACK4APP_BASE_URL'] ?? baseUrl;
      appId = dotenv.env['BACK4APP_APP_ID'] ?? appId;
      restApiKey = dotenv.env['BACK4APP_REST_API_KEY'] ?? restApiKey;
    }

    // Try secure storage for any missing values
    final storage = const FlutterSecureStorage();
    baseUrl = baseUrl.isNotEmpty ? baseUrl : (await storage.read(key: 'BACK4APP_BASE_URL')) ?? '';
    appId = appId.isNotEmpty ? appId : (await storage.read(key: 'BACK4APP_APP_ID')) ?? '';
    restApiKey = restApiKey.isNotEmpty ? restApiKey : (await storage.read(key: 'BACK4APP_REST_API_KEY')) ?? '';
  }

  /// Set credentials at runtime (useful for injecting values from a build system
  /// or when the values are provided at runtime). These values are used by
  /// services to build request headers. Calling this does not persist values
  /// to secure storage; to persist, write to secure storage separately.
  static void setCredentials({required String baseUrl, required String appId, required String restApiKey}) {
    Back4AppConfig.baseUrl = baseUrl;
    Back4AppConfig.appId = appId;
    Back4AppConfig.restApiKey = restApiKey;
  }
}

