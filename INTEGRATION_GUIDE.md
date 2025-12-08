# 🔗 Guia de Integração Java/Kotlin

Este guia mostra como integrar o Dart AST Smart Merge CLI em projetos Java/Kotlin.

## 📦 Opções de Distribuição

### Opção 1: Executável Nativo (Recomendado ✅)

Compile o projeto Dart para um executável nativo único:

```bash
cd dart-diff-cli
dart compile exe bin/main.dart -o dart-ast-merge
```

**Vantagens:**
- ✅ Arquivo único (~10-15 MB)
- ✅ Não requer Dart SDK instalado
- ✅ Rápido (execução nativa)
- ✅ Funciona em qualquer sistema (compile para o OS alvo)

**Distribuição:**
```
seu-projeto/
├── lib/
├── src/
└── tools/
    └── dart-ast-merge    # Copie o executável aqui
```

### Opção 2: Executar via Dart SDK

Se o Dart SDK estiver disponível:

```bash
dart run dart-diff-cli/bin/main.dart --current-file ... --generated-file ... --output-file ...
```

**Desvantagens:**
- ❌ Requer Dart SDK instalado
- ❌ Mais lento (interpretado)

### ~~Opção 3: Compilar para JavaScript~~ ❌

**NÃO é possível** compilar para JavaScript porque:
- O projeto usa `dart:io` (file system)
- `dart:io` não funciona em navegadores
- `dart compile js` é apenas para aplicações web

## 🎯 Integração com Java

### Passo 1: Compile o Executável

```bash
cd /Users/taylson/developer/dart-diff-cli
./compile.sh
# ou
dart compile exe bin/main.dart -o dart-ast-merge
```

### Passo 2: Copie para seu Projeto Java

```bash
cp dart-ast-merge /path/to/seu-projeto-java/tools/
```

### Passo 3: Use a Classe Java

Copie o arquivo `integration/JavaIntegration.java` para seu projeto:

```java
package com.seupackage;

import com.example.dartmerge.DartAstMerger;

public class Main {
    public static void main(String[] args) throws Exception {
        // Caminho relativo ao projeto
        String executable = "tools/dart-ast-merge";
        
        DartAstMerger merger = new DartAstMerger(executable);
        
        var result = merger.merge(
            "lib/widgets/my_widget.dart",
            "lib/widgets/my_widget.generated.dart",
            "lib/widgets/my_widget.dart"
        );
        
        if (result.isSuccess()) {
            System.out.println("✅ Merge concluído!");
        } else {
            System.err.println("❌ Erro: " + result.getOutput());
        }
    }
}
```

## 🎯 Integração com Kotlin

### Passo 1: Compile o Executável

```bash
cd /Users/taylson/developer/dart-diff-cli
dart compile exe bin/main.dart -o dart-ast-merge
```

### Passo 2: Copie para seu Projeto Kotlin

```bash
cp dart-ast-merge /path/to/seu-projeto-kotlin/tools/
```

### Passo 3: Use a Classe Kotlin

Copie o arquivo `integration/KotlinIntegration.kt` para seu projeto:

```kotlin
package com.seupackage

import com.example.dartmerge.DartAstMerger

fun main() {
    val executable = "tools/dart-ast-merge"
    val merger = DartAstMerger(executable)
    
    val result = merger.merge(
        currentFile = "lib/widgets/my_widget.dart",
        generatedFile = "lib/widgets/my_widget.generated.dart",
        outputFile = "lib/widgets/my_widget.dart"
    )
    
    when {
        result.success -> println("✅ Merge concluído em ${result.executionTime}ms")
        else -> println("❌ Erro: ${result.output}")
    }
}
```

### Exemplo com Coroutines

```kotlin
import kotlinx.coroutines.*

suspend fun mergeAsync() {
    val merger = DartAstMerger("tools/dart-ast-merge")
    
    val result = merger.mergeAsync(
        currentFile = "lib/my_widget.dart",
        generatedFile = "lib/my_widget.g.dart",
        outputFile = "lib/my_widget.dart"
    )
    
    println("Merge finalizado: ${result.success}")
}

fun main() = runBlocking {
    mergeAsync()
}
```

## 🔧 Integração com Build Tools

### Gradle (Kotlin DSL)

Adicione ao seu `build.gradle.kts`:

```kotlin
tasks.register("dartMerge") {
    group = "codegen"
    description = "Merge Dart files"
    
    doLast {
        exec {
            commandLine(
                "tools/dart-ast-merge",
                "--current-file", "lib/my_widget.dart",
                "--generated-file", "lib/my_widget.generated.dart",
                "--output-file", "lib/my_widget.dart"
            )
        }
    }
}

// Executar antes de compilar
tasks.named("compileKotlin") {
    dependsOn("dartMerge")
}
```

Execute:
```bash
./gradlew dartMerge
```

### Maven

Adicione ao seu `pom.xml`:

```xml
<plugin>
    <groupId>org.codehaus.mojo</groupId>
    <artifactId>exec-maven-plugin</artifactId>
    <version>3.1.0</version>
    <executions>
        <execution>
            <id>dart-merge</id>
            <phase>generate-sources</phase>
            <goals>
                <goal>exec</goal>
            </goals>
            <configuration>
                <executable>${project.basedir}/tools/dart-ast-merge</executable>
                <arguments>
                    <argument>--current-file</argument>
                    <argument>lib/my_widget.dart</argument>
                    <argument>--generated-file</argument>
                    <argument>lib/my_widget.generated.dart</argument>
                    <argument>--output-file</argument>
                    <argument>lib/my_widget.dart</argument>
                </arguments>
            </configuration>
        </execution>
    </executions>
</plugin>
```

Execute:
```bash
mvn generate-sources
```

## 🚀 Uso em Pipelines de Code Generation

### Com build_runner (Flutter)

```kotlin
// 1. Gerar código
exec {
    commandLine("dart", "run", "build_runner", "build")
}

// 2. Merge com código existente
exec {
    commandLine(
        "tools/dart-ast-merge",
        "-c", "lib/models/user.dart",
        "-g", "lib/models/user.g.dart",
        "-o", "lib/models/user.dart"
    )
}
```

### Com Annotation Processors

```java
// No seu annotation processor
public void mergeGeneratedCode(String originalFile, String generatedFile) {
    try {
        DartAstMerger merger = new DartAstMerger("tools/dart-ast-merge");
        var result = merger.merge(originalFile, generatedFile, originalFile);
        
        if (!result.isSuccess()) {
            messager.printMessage(
                Diagnostic.Kind.ERROR,
                "Falha no merge: " + result.getOutput()
            );
        }
    } catch (Exception e) {
        messager.printMessage(Diagnostic.Kind.ERROR, e.getMessage());
    }
}
```

## 📁 Estrutura de Projeto Recomendada

```
seu-projeto/
├── lib/
│   └── generated/
│       ├── *.dart           # Código gerado
│       └── *.g.dart         # Arquivos temporários
├── src/
│   └── main/
│       ├── java/
│       │   └── DartMerger.java
│       └── kotlin/
│           └── DartMerger.kt
├── tools/
│   ├── dart-ast-merge       # Executável (Linux/Mac)
│   ├── dart-ast-merge.exe   # Executável (Windows)
│   └── merge-all.sh         # Script helper
├── build.gradle.kts
└── pom.xml
```

## 🔒 Distribuição do Executável

### Para Múltiplas Plataformas

Compile para cada plataforma:

```bash
# No Mac (para Mac/Linux)
dart compile exe bin/main.dart -o dart-ast-merge-macos

# No Linux (para Linux)
dart compile exe bin/main.dart -o dart-ast-merge-linux

# No Windows (para Windows)
dart compile exe bin/main.dart -o dart-ast-merge.exe
```

Detecte a plataforma em tempo de execução:

```kotlin
val os = System.getProperty("os.name").lowercase()
val executable = when {
    os.contains("windows") -> "tools/dart-ast-merge.exe"
    os.contains("mac") -> "tools/dart-ast-merge-macos"
    else -> "tools/dart-ast-merge-linux"
}
```

## ⚡ Performance

Benchmarks típicos:

| Tamanho do Arquivo | Tempo de Execução |
|--------------------|-------------------|
| < 1K linhas | 100-150ms |
| 1-5K linhas | 150-300ms |
| > 5K linhas | 300-1000ms |

**Overhead de chamada via ProcessBuilder:** ~20-50ms

## 🐛 Troubleshooting

### Erro: "Permission denied"

```bash
chmod +x tools/dart-ast-merge
```

### Erro: "File not found"

Verifique o caminho:
```java
File executable = new File("tools/dart-ast-merge");
if (!executable.exists()) {
    throw new RuntimeException("Executável não encontrado: " + 
                               executable.getAbsolutePath());
}
```

### Processo trava/timeout

Aumente o timeout:
```kotlin
val merger = DartAstMerger("tools/dart-ast-merge", timeoutSeconds = 60)
```

## 📊 Exemplo Completo End-to-End

```kotlin
import com.example.dartmerge.DartAstMerger
import java.nio.file.Paths

class FlutterCodeGenerator {
    
    private val merger = DartAstMerger("tools/dart-ast-merge")
    private val projectRoot = Paths.get(System.getProperty("user.dir"))
    
    fun generateAndMerge(widgetName: String) {
        // 1. Gerar código
        generateCode(widgetName)
        
        // 2. Merge com código existente
        val result = merger.mergeRelative(
            projectRoot = projectRoot,
            currentFile = "lib/widgets/${widgetName}.dart",
            generatedFile = "lib/generated/${widgetName}.g.dart",
            outputFile = "lib/widgets/${widgetName}.dart"
        )
        
        // 3. Verificar resultado
        if (result.success) {
            println("✅ $widgetName merged successfully in ${result.executionTime}ms")
        } else {
            throw RuntimeException("Merge failed: ${result.output}")
        }
    }
    
    private fun generateCode(widgetName: String) {
        // Seu código de geração aqui
    }
}

fun main() {
    val generator = FlutterCodeGenerator()
    generator.generateAndMerge("MyWidget")
    generator.generateAndMerge("AnotherWidget")
}
```

## 🎓 Melhores Práticas

1. **✅ Sempre compile para a plataforma alvo**
2. **✅ Inclua o executável no controle de versão (Git LFS)**
3. **✅ Use caminhos relativos ao projeto**
4. **✅ Implemente tratamento de erros robusto**
5. **✅ Configure timeouts apropriados**
6. **✅ Log a saída para debugging**
7. **✅ Valide arquivos antes do merge**

## 🔗 Recursos Adicionais

- [JavaIntegration.java](integration/JavaIntegration.java) - Implementação completa Java
- [KotlinIntegration.kt](integration/KotlinIntegration.kt) - Implementação completa Kotlin
- [build.gradle.kts](integration/build.gradle.kts) - Exemplo Gradle
- [pom.xml](integration/pom.xml) - Exemplo Maven

---

**Pronto para usar!** 🚀 O executável único torna a integração simples e eficiente.

