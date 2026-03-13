plugins {
    id("com.android.application")
    id("kotlin-android")
    // El plugin de Flutter
    id("dev.flutter.flutter-gradle-plugin")
    // AGREGADO: Plugin de Google Services en formato Kotlin DSL
    id("com.google.gms.google-services")
}

android {
    namespace = "com.saurc.app.saurc"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.saurc.app.saurc"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

// SECCIÓN DE DEPENDENCIAS AGREGADA
dependencies {
    // Importa la BoM de Firebase para gestionar versiones automáticamente
    implementation(platform("com.google.firebase:firebase-bom:33.1.0"))

    // Ejemplo: Si usas Analytics, agrégalo así (sin versión)
    implementation("com.google.firebase:firebase-analytics")
    
    // Si usas otras funciones de Firebase para SAURC, añádelas aquí abajo
}