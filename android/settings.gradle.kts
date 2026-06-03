plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.tatapower.greengears"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17" // Correct Kotlin DSL syntax
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID
        applicationId = "com.tatapower.holidayhomes"
        minSdk = 29
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["appAuthRedirectScheme"] = "msauth"
    }

    buildTypes {
        release {
            // Signing with debug keys for now
            signingConfig = signingConfigs.getByName("debug")
        }
        debug {
            // Optional: ensure debug build also has placeholder
            manifestPlaceholders["appAuthRedirectScheme"] = "msauth"
        }
    }
}

flutter {
    source = "../.."
}
