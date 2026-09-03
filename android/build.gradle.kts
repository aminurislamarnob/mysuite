allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
// image_cropper 9.1.0 pins its own module to compileSdk 33 while depending on
// androidx libraries that require 34+, so it cannot build as published. Raising
// any plugin that asks for less than that fixes it without touching the
// package, and is a no-op once the plugin catches up. This has to be registered
// before the evaluationDependsOn below, which evaluates the projects.
subprojects {
    afterEvaluate {
        val android = extensions.findByName("android")
        if (android is com.android.build.gradle.BaseExtension) {
            val current = android.compileSdkVersion
                ?.removePrefix("android-")
                ?.toIntOrNull()
            if (current != null && current < 34) {
                android.compileSdkVersion(34)
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
