# The ML Kit text-recognition plugin dispatches over every script ML Kit
# supports — Chinese, Devanagari, Japanese, Korean — but the app depends on the
# Latin recogniser alone, so those four artefacts are not on the classpath. R8
# sees the references, cannot resolve them, and fails the release build. The
# branches are unreachable: `camera_scan_screen.dart` only ever asks for Latin.
#
# Adding the other recognisers instead would work, and cost several MB of
# bundled models for scripts the scanner never asks for.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
