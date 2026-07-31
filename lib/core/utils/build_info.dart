// Diagnostic build marker, injected via --dart-define at build time
// (flutter build apk --dart-define=GIT_HASH=... --dart-define=BUILD_TIME=...).
// Lets a screenshot of "О приложении" prove which exact commit and build
// a given install actually contains, instead of relying on versionCode
// alone or on assuming a manual install replaced the previous binary.
class BuildInfo {
  static const String gitHash =
      String.fromEnvironment('GIT_HASH', defaultValue: 'dev');
  static const String buildTime =
      String.fromEnvironment('BUILD_TIME', defaultValue: '');
}
