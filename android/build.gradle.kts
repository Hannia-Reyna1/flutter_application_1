buildscript {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.1.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.0")
    }
}
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir = rootProject.layout.buildDirectory.dir("../../build")
rootProject.layout.buildDirectory.set(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.map { it.dir(project.name) }
    project.layout.buildDirectory.set(newSubprojectBuildDir)
    evaluationDependsOn(":app")  // ✅ Se optimiza la dependencia del módulo
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}