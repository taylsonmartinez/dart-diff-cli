// build.gradle.kts - Exemplo de integração com Gradle

plugins {
    kotlin("jvm") version "1.9.0"
    application
}

repositories {
    mavenCentral()
}

dependencies {
    implementation(kotlin("stdlib"))
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.7.3")
}

// Task customizada para executar o merge durante o build
tasks.register("dartMerge") {
    group = "dart"
    description = "Executa o merge de arquivos Dart"
    
    doLast {
        val executablePath = project.file("dart-ast-merge").absolutePath
        
        exec {
            commandLine(
                executablePath,
                "--current-file", "src/main/dart/current.dart",
                "--generated-file", "src/main/dart/generated.dart",
                "--output-file", "src/main/dart/merged.dart"
            )
        }
    }
}

// Task para compilar o executável Dart (se necessário)
tasks.register("compileDartMerger") {
    group = "dart"
    description = "Compila o Dart AST Merger para executável nativo"
    
    doLast {
        exec {
            workingDir = file("dart-diff-cli")
            commandLine("dart", "compile", "exe", "bin/main.dart", "-o", "../dart-ast-merge")
        }
    }
}

// Integração com build: executa merge antes de compilar
tasks.named("compileKotlin") {
    dependsOn("dartMerge")
}

// Configuração do aplicativo
application {
    mainClass.set("com.example.dartmerge.MainKt")
}

