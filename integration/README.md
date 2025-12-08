# 🔗 Integration Examples

Esta pasta contém exemplos completos de integração do Dart AST Smart Merge CLI com Java/Kotlin.

## 📁 Arquivos

### Implementações

| Arquivo | Descrição |
|---------|-----------|
| `JavaIntegration.java` | Classe completa Java para executar o merge |
| `KotlinIntegration.kt` | Classe completa Kotlin com suporte a Coroutines |

### Build Tools

| Arquivo | Descrição |
|---------|-----------|
| `build.gradle.kts` | Exemplo de integração com Gradle (Kotlin DSL) |
| `pom.xml` | Exemplo de integração com Maven |

## 🚀 Como Usar

### 1. Compile o Executável

```bash
cd ..
dart compile exe bin/main.dart -o dart-ast-merge
```

### 2. Escolha sua Linguagem

#### Java

```java
DartAstMerger merger = new DartAstMerger("./dart-ast-merge");
MergeResult result = merger.merge(
    "current.dart",
    "generated.dart", 
    "output.dart"
);
```

#### Kotlin

```kotlin
val merger = DartAstMerger("./dart-ast-merge")
val result = merger.merge(
    currentFile = "current.dart",
    generatedFile = "generated.dart",
    outputFile = "output.dart"
)
```

### 3. Integre com seu Build

#### Gradle

```bash
./gradlew dartMerge
```

#### Maven

```bash
mvn generate-sources
```

## 📖 Documentação Completa

Leia o [INTEGRATION_GUIDE.md](../INTEGRATION_GUIDE.md) para:
- Guia completo de integração
- Exemplos end-to-end
- Integração com CI/CD
- Troubleshooting
- Melhores práticas

## ⚡ Quick Start

### Java

```java
package com.example;

import com.example.dartmerge.DartAstMerger;

public class Example {
    public static void main(String[] args) throws Exception {
        DartAstMerger merger = new DartAstMerger("tools/dart-ast-merge");
        
        var result = merger.merge(
            "lib/my_widget.dart",
            "lib/my_widget.generated.dart",
            "lib/my_widget.dart"
        );
        
        System.out.println(result.isSuccess() ? "✅ Success" : "❌ Failed");
    }
}
```

### Kotlin

```kotlin
package com.example

import com.example.dartmerge.DartAstMerger

fun main() {
    val merger = DartAstMerger("tools/dart-ast-merge")
    
    val result = merger.merge(
        currentFile = "lib/my_widget.dart",
        generatedFile = "lib/my_widget.generated.dart",
        outputFile = "lib/my_widget.dart"
    )
    
    println(if (result.success) "✅ Success" else "❌ Failed")
}
```

## 🎯 Características

✅ **Executável Único** - Sem dependências do Dart SDK  
✅ **Rápido** - Execução nativa (100-300ms típico)  
✅ **Fácil Integração** - Copy-paste ready  
✅ **Type-Safe** - Classes Java/Kotlin completas  
✅ **Async Support** - Coroutines para Kotlin  
✅ **Build Integration** - Gradle e Maven prontos  

## 💡 Casos de Uso

### 1. Geração de Código Flutter

```kotlin
// Gerar
exec { commandLine("dart", "run", "build_runner", "build") }

// Merge
merger.merge("lib/user.dart", "lib/user.g.dart", "lib/user.dart")
```

### 2. Annotation Processing

```java
@Override
public boolean process(Set<? extends TypeElement> annotations, 
                      RoundEnvironment roundEnv) {
    // Gerar código
    generateCode();
    
    // Merge automático
    mergeResults();
    
    return true;
}
```

### 3. CI/CD Pipeline

```yaml
- name: Generate and Merge
  run: |
    dart run build_runner build
    ./tools/dart-ast-merge -c lib/app.dart -g lib/app.g.dart -o lib/app.dart
```

## 📊 Performance

| Operação | Tempo |
|----------|-------|
| Processo startup | ~20-50ms |
| Parse AST | ~30-80ms |
| Merge logic | ~50-150ms |
| Format output | ~10-30ms |
| **Total** | **100-300ms** |

## 🔧 Customização

### Timeout Customizado

```kotlin
val merger = DartAstMerger(
    executablePath = "tools/dart-ast-merge",
    timeoutSeconds = 60  // 1 minuto
)
```

### Error Handling

```java
try {
    MergeResult result = merger.merge(...);
    if (!result.isSuccess()) {
        logger.error("Merge failed: {}", result.getOutput());
        throw new BuildException("Merge failed");
    }
} catch (IOException e) {
    logger.error("IO error", e);
}
```

### Logging

```kotlin
val result = merger.merge(...)
println("""
    Status: ${result.success}
    Exit Code: ${result.exitCode}
    Time: ${result.executionTime}ms
    Output:
    ${result.output}
""".trimIndent())
```

## 🐛 Troubleshooting

### Executável não encontrado

```kotlin
// Use caminho absoluto
val executable = File("tools/dart-ast-merge").absolutePath
val merger = DartAstMerger(executable)
```

### Permission denied

```bash
chmod +x tools/dart-ast-merge
```

### Processo trava

```kotlin
// Aumente o timeout
val merger = DartAstMerger("tools/dart-ast-merge", timeoutSeconds = 120)
```

## 🌐 Multiplataforma

### Detectar SO e usar executável correto

```kotlin
val os = System.getProperty("os.name").lowercase()
val executable = when {
    os.contains("windows") -> "tools/dart-ast-merge.exe"
    os.contains("mac") -> "tools/dart-ast-merge-macos"
    else -> "tools/dart-ast-merge-linux"
}
val merger = DartAstMerger(executable)
```

## 📚 Recursos

- [INTEGRATION_GUIDE.md](../INTEGRATION_GUIDE.md) - Guia completo
- [README.md](../README.md) - Documentação do projeto
- [USAGE.md](../USAGE.md) - Guia de uso geral

---

**Pronto para integrar!** 🚀 Copie os arquivos e comece a usar.

