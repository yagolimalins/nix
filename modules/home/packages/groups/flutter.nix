# Flutter stable + immutable Android SDK for a physical device.
# Linux/web toolchains come from the nixpkgs flutter wrapper. No emulator.
{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:

let
  cfg = config.${namespace}.packages;
  on = lib.${namespace}.packageGroupOn cfg;

  # Flutter 3.41.9 (packages/flutter_tools/lib/src/android/gradle_utils.dart).
  # Any other NDK makes Gradle try to write into ANDROID_HOME, which is in the store.
  # latest platforms here is 37.0; the template compileSdk is 36, and that platform
  # cannot be fetched into a read-only SDK either.
  flutterNdkVersion = "28.2.13676358";
  flutterPlatformVersion = "36";

  androidEnv = pkgs.androidenv.override { licenseAccepted = true; };
  androidComposition = androidEnv.composeAndroidPackages {
    platformVersions = [ flutterPlatformVersion ];
    # Flutter 3.41's Android Gradle Plugin installs build-tools 35.0.0 on the
    # first APK build. The SDK is read-only, so that package has to be here.
    # "latest" stays for the aapt2 override below.
    buildToolsVersions = [
      "35.0.0"
      "latest"
    ];
    includeEmulator = false;
    includeSystemImages = false;
    includeNDK = true;
    ndkVersions = [ flutterNdkVersion ];
    # NDK r28 asks sdkmanager for cmake;3.22.1. Default here is latest (4.1.2).
    includeCmake = true;
    cmakeVersions = [
      "3.22.1"
      "latest"
    ];
    # `flutter doctor` runs `sdkmanager --licenses`, which wants every license in
    # repo.json, not only android-sdk-license. licenses/ is read-only in the store.
    extraLicenses = [
      "android-googletv-license"
      "android-googlexr-license"
      "android-sdk-arm-dbt-license"
      "android-sdk-preview-license"
      "google-gdk-license"
      "intel-android-extra-license"
      "intel-android-sysimage-license"
      "microxr-sysimage-license"
      "mips-android-sysimage-license"
    ];
  };
  androidSdk = androidComposition.androidsdk;
  sdkRoot = "${androidSdk}/libexec/android-sdk";

  # Gradle downloads an unpatched aapt2 from Maven. AGP treats
  # android.aapt2FromMavenOverride as a file and then looks for a binary named
  # "aapt2" in its parent directory, so the store path itself cannot be the binary
  # (that parent is /nix/store).
  aapt2 = pkgs.runCommand "android-aapt2" { } ''
    mkdir -p $out
    src=$(ls -1 ${sdkRoot}/build-tools/*/aapt2 | sort -V | tail -n 1)
    ln -s "$(readlink -f "$src")" $out/aapt2
  '';
in
{
  config = lib.mkIf (on "flutter") {
    home.packages = [
      pkgs.flutter
      pkgs.jdk17
      androidSdk
      pkgs.mesa-demos # eglinfo, used by `flutter doctor` for the Linux toolchain
    ];

    # sdk-symlink joins the unwrapped SDK, so bin/dart is already next to flutter
    # (Helix's built-in Dart language server).
    home.sessionPath = [ "${config.home.homeDirectory}/.pub-cache/bin" ];

    home.sessionVariables = {
      ANDROID_HOME = sdkRoot;
      ANDROID_SDK_ROOT = sdkRoot;
      JAVA_HOME = pkgs.jdk17.home;
      CHROME_EXECUTABLE = lib.getExe pkgs.chromium;
      GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${aapt2}/aapt2";
    };
  };
}
