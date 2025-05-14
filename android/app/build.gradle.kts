plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}
android {
    namespace = "com.example.flutter_application_1"
    compileSdk = 34  // ✅ Se actualizó para compatibilidad con Firebase y otros paquetes
    ndkVersion = "27.0.12077973"

    compileOptions {
        java {
            toolchain.languageVersion.set(JavaLanguageVersion.of(17))  // 🔧 Se usa correctamente Java 17
        }
    }

    kotlinOptions {
        jvmTarget = "17"  // 🔧 Se actualiza para evitar el error de incompatibilidad
    }

    defaultConfig {
        applicationId = "com.example.flutter_application_1"
        minSdk = 26  // ✅ Se subió para evitar problemas con dependencias recientes
        targetSdk = 35  // ✅ Se alineó con `compileSdk`
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        release {
            isMinifyEnabled = true  // ✅ Se activa la reducción de código no utilizado
            isShrinkResources = true  // ✅ Se activa la eliminación de recursos no usados
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            signingConfig = signingConfigs.getByName("debug")  // ✅ Se asegura la firma correcta
        }
    }
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")  // 🔧 Se actualiza para compatibilidad con Java 17
    implementation("org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.0")  // 🔧 Se asegura la versión correcta
    implementation("com.android.tools.build:gradle:8.0.0")  // ✅ Se ajusta la versión de Gradle para evitar errores
    implementation("dev.flutter:flutter_embedding:3.9.0")

    
    // 🔧 Excluir bibliotecas duplicadas que estaban generando conflictos
    configurations.all {
        exclude(group = "org.jetbrains", module = "annotations")
        exclude(group = "com.sun.activation", module = "javax.activation")
    }
}