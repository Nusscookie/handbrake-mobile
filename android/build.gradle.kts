allprojects {
    repositories {
        google()
        mavenCentral()
        maven {
            url = uri("https://jitpack.io")
        }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// AGP 8+ no longer allows namespace to be set via the package="" attribute in
// AndroidManifest.xml (e.g. isar_flutter_libs 3.1.0+1 still uses this old style).
// plugins.withId fires lazily when the plugin is first applied to each project —
// i.e. during that project's own evaluation — so it is never "too late".
allprojects {
    plugins.withId("com.android.library") {
        configure<com.android.build.gradle.LibraryExtension> {
            if (namespace == null) {
                namespace = project.group.toString()
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
