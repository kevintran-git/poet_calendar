import 'package:envied/envied.dart';
part 'env.g.dart';

@Envied(path: ".env")
abstract class Env {
  @EnviedField(varName: 'OPEN_AI_API_KEY')
  static const openAiKey = _Env.openAiKey;
  @EnviedField(varName: 'GOOGLE_CLIENT_ID')
  static const googleClientId = _Env.googleClientId;
  @EnviedField(varName: 'WEATHER_API_KEY')
  static const weatherApiKey = _Env.weatherApiKey;
}