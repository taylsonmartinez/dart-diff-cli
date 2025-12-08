package com.example.dartmerge

import java.io.BufferedReader
import java.io.File
import java.io.IOException
import java.nio.file.Path
import java.nio.file.Paths
import java.util.concurrent.TimeUnit

/**
 * Integração Kotlin com o Dart AST Merge CLI
 * 
 * Exemplo de uso:
 * ```kotlin
 * val merger = DartAstMerger("/path/to/dart-ast-merge")
 * val result = merger.merge(
 *     currentFile = "src/main/dart/current.dart",
 *     generatedFile = "src/main/dart/generated.dart",
 *     outputFile = "src/main/dart/output.dart"
 * )
 * if (result.isSuccess) {
 *     println("Merge concluído em ${result.executionTime}ms")
 * }
 * ```
 */
class DartAstMerger(
    private val executablePath: String,
    private val timeoutSeconds: Long = 30
) {
    
    init {
        val executable = File(executablePath)
        require(executable.exists() && executable.canExecute()) {
            "Executável não encontrado ou sem permissão: $executablePath"
        }
    }
    
    /**
     * Executa o merge de arquivos Dart
     * 
     * @param currentFile Arquivo com modificações do usuário (P1)
     * @param generatedFile Arquivo gerado (P2)
     * @param outputFile Arquivo de saída (P3)
     * @return Resultado do merge
     */
    fun merge(
        currentFile: String,
        generatedFile: String,
        outputFile: String
    ): MergeResult {
        val startTime = System.currentTimeMillis()
        
        // Constrói o comando
        val command = listOf(
            executablePath,
            "--current-file", currentFile,
            "--generated-file", generatedFile,
            "--output-file", outputFile
        )
        
        // Executa o processo
        val process = ProcessBuilder(command)
            .redirectErrorStream(true)
            .start()
        
        // Captura a saída
        val output = process.inputStream.bufferedReader().use(BufferedReader::readText)
        
        // Aguarda conclusão com timeout
        val finished = process.waitFor(timeoutSeconds, TimeUnit.SECONDS)
        
        if (!finished) {
            process.destroyForcibly()
            throw IOException("Processo excedeu o timeout de $timeoutSeconds segundos")
        }
        
        val executionTime = System.currentTimeMillis() - startTime
        val exitCode = process.exitValue()
        
        return MergeResult(
            success = exitCode == 0,
            exitCode = exitCode,
            output = output,
            executionTime = executionTime
        )
    }
    
    /**
     * Executa o merge com caminhos relativos ao diretório do projeto
     */
    fun mergeRelative(
        projectRoot: Path,
        currentFile: String,
        generatedFile: String,
        outputFile: String
    ): MergeResult {
        return merge(
            currentFile = projectRoot.resolve(currentFile).toString(),
            generatedFile = projectRoot.resolve(generatedFile).toString(),
            outputFile = projectRoot.resolve(outputFile).toString()
        )
    }
    
    /**
     * Executa o merge de forma assíncrona (suspend function)
     */
    suspend fun mergeAsync(
        currentFile: String,
        generatedFile: String,
        outputFile: String
    ): MergeResult = kotlinx.coroutines.withContext(kotlinx.coroutines.Dispatchers.IO) {
        merge(currentFile, generatedFile, outputFile)
    }
    
    /**
     * Resultado do merge
     */
    data class MergeResult(
        val success: Boolean,
        val exitCode: Int,
        val output: String,
        val executionTime: Long
    ) {
        override fun toString(): String {
            return "MergeResult(success=$success, exitCode=$exitCode, executionTime=${executionTime}ms)"
        }
    }
}

/**
 * Extension function para facilitar o uso
 */
fun String.mergeDartFiles(
    currentFile: String,
    generatedFile: String,
    outputFile: String,
    timeout: Long = 30
): DartAstMerger.MergeResult {
    val merger = DartAstMerger(this, timeout)
    return merger.merge(currentFile, generatedFile, outputFile)
}

/**
 * Exemplo de uso
 */
fun main() {
    try {
        // Caminho para o executável (ajuste conforme necessário)
        val executablePath = "./dart-ast-merge"
        
        val merger = DartAstMerger(executablePath)
        
        // Exemplo 1: Uso básico
        val result = merger.merge(
            currentFile = "example/current_file.dart",
            generatedFile = "example/generated_file.dart",
            outputFile = "example/merged_output.dart"
        )
        
        println("Status: ${if (result.success) "✅ Sucesso" else "❌ Falha"}")
        println("Tempo de execução: ${result.executionTime}ms")
        println("Saída:\n${result.output}")
        
        // Exemplo 2: Com extension function
        val result2 = executablePath.mergeDartFiles(
            currentFile = "lib/my_widget.dart",
            generatedFile = "lib/my_widget.g.dart",
            outputFile = "lib/my_widget.dart"
        )
        
        when {
            result2.success -> println("Merge concluído com sucesso!")
            else -> println("Erro no merge: ${result2.output}")
        }
        
        // Exemplo 3: Caminhos relativos
        val projectRoot = Paths.get(System.getProperty("user.dir"))
        val result3 = merger.mergeRelative(
            projectRoot = projectRoot,
            currentFile = "lib/screens/home.dart",
            generatedFile = "lib/screens/home.generated.dart",
            outputFile = "lib/screens/home.merged.dart"
        )
        
        println(result3)
        
    } catch (e: Exception) {
        System.err.println("Erro no merge: ${e.message}")
        e.printStackTrace()
    }
}

/**
 * Exemplo de uso com Coroutines
 */
suspend fun exampleWithCoroutines() {
    val merger = DartAstMerger("./dart-ast-merge")
    
    val result = merger.mergeAsync(
        currentFile = "example/current_file.dart",
        generatedFile = "example/generated_file.dart",
        outputFile = "example/merged_output.dart"
    )
    
    println("Merge concluído: ${result.success}")
}

