import 'import_theme.dart'; // File penampung warna Anda

class EnvConfig {
  final String appName;
  final bool isDev;

  EnvConfig({required this.appName, required this.isDev});

  static late EnvConfig shared;
}