import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Env {
  Env({
    required this.apiBaseUrl,
    required this.apiPrivateSignatureKey,
    required this.channel,
  });
  final String apiBaseUrl;
  final String apiPrivateSignatureKey;
  final String channel;

  factory Env.fromEnv() {
    final baseUrl = dotenv.get(
      'API_URL',
      fallback: 'https://test-api.hahahub.xyz',
    );

    final apiKey = dotenv.get(
      "API_PRIVATE_SIGNATURE_KEY",
      fallback: "Of5zErSuAbKA=aXCSl8DQF-CUUKk5BTK",
    );

    final channel = dotenv.get(
      Platform.isAndroid ? 'ANDROID_ENV_CHANNEL' : 'IOS_ENV_CHANNEL',
      fallback: 'AND_US_GG_001',
    );

    return Env(
      apiBaseUrl: baseUrl,
      apiPrivateSignatureKey: apiKey,
      channel: channel,
    );
  }
}

final envProvider = Provider<Env>((ref) => Env.fromEnv());
