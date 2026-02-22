# TensorFlow Lite Speech Command Recognition Android Demo

> **Notice:** This project was developed several years ago and was building successfully at the time (around five years ago). Due to changes in dependencies and environments, it may no longer build without modification.

### Overview

This app performs recognition of speech Commands on mobile, highlighting the spoken word.

## Building from Source

This project was originally built with older versions of Android Studio and the Android Gradle Plugin. The following steps have been taken to get the project building with modern tools.

1.  **Gradle and Android Gradle Plugin:** The project has been updated to use a modern version of both Gradle and the Android Gradle Plugin. You can see the specific versions in the `build.gradle` and `gradle/wrapper/gradle-wrapper.properties` files.

2.  **Dependencies:** All dependencies have been updated to their latest stable versions. This includes the TensorFlow Lite library and the AndroidX libraries.

3.  **AndroidX Migration:** The project has been fully migrated to AndroidX. This involved updating the dependencies in the `app/build.gradle` file and updating the code to use the new `androidx.*` package names.

4.  **API Changes:** The code has been updated to reflect changes in the TensorFlow Lite API. This includes using `Interpreter.Options` to configure the interpreter and its delegates.

5.  **Manifest and Permissions:** The `AndroidManifest.xml` has been updated to meet the requirements of modern Android versions. This includes explicitly setting the `android:exported` attribute for the main activity and adding runtime permission checks for the microphone.

With these changes, you should be able to open this project in a recent version of Android Studio and build it without any issues.
