plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.habitrack"
    compileSdk = 35  // Updated to 35 as required by dependencies
    ndkVersion = "27.0.12077973"  // Updated NDK version as required

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11  // Change to Java 11
        targetCompatibility = JavaVersion.VERSION_11  // Change to Java 11
        isCoreLibraryDesugaringEnabled = true  // Enable desugaring
    }

    kotlinOptions {
        jvmTarget = "11"  // Change to match Java 11
    }

    defaultConfig {
        applicationId = "com.example.habitrack"
        minSdk = 21
        targetSdk = 33
        versionCode = 1
        versionName = "1.0.0"
    }
}

dependencies {
    // Add the desugaring dependency
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:1.2.2")
}
