package com.example.dartmerge;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;

/**
 * Integração Java com o Dart AST Merge CLI
 * 
 * Exemplo de uso:
 * <pre>
 * DartAstMerger merger = new DartAstMerger("/path/to/dart-ast-merge");
 * MergeResult result = merger.merge(
 *     "src/main/dart/current.dart",
 *     "src/main/dart/generated.dart",
 *     "src/main/dart/output.dart"
 * );
 * if (result.isSuccess()) {
 *     System.out.println("Merge concluído em " + result.getExecutionTime() + "ms");
 * }
 * </pre>
 */
public class DartAstMerger {
    
    private final String executablePath;
    private final long timeoutSeconds;
    
    /**
     * Cria um novo merger com caminho para o executável
     * 
     * @param executablePath Caminho para o executável dart-ast-merge
     */
    public DartAstMerger(String executablePath) {
        this(executablePath, 30); // 30 segundos de timeout padrão
    }
    
    /**
     * Cria um novo merger com timeout customizado
     * 
     * @param executablePath Caminho para o executável dart-ast-merge
     * @param timeoutSeconds Timeout em segundos
     */
    public DartAstMerger(String executablePath, long timeoutSeconds) {
        this.executablePath = executablePath;
        this.timeoutSeconds = timeoutSeconds;
        
        // Valida se o executável existe
        File executable = new File(executablePath);
        if (!executable.exists() || !executable.canExecute()) {
            throw new IllegalArgumentException(
                "Executável não encontrado ou sem permissão: " + executablePath
            );
        }
    }
    
    /**
     * Executa o merge de arquivos Dart
     * 
     * @param currentFile Arquivo com modificações do usuário (P1)
     * @param generatedFile Arquivo gerado (P2)
     * @param outputFile Arquivo de saída (P3)
     * @return Resultado do merge
     * @throws IOException Se houver erro de I/O
     * @throws InterruptedException Se o processo for interrompido
     */
    public MergeResult merge(String currentFile, String generatedFile, String outputFile) 
            throws IOException, InterruptedException {
        
        long startTime = System.currentTimeMillis();
        
        // Constrói o comando
        List<String> command = new ArrayList<>();
        command.add(executablePath);
        command.add("--current-file");
        command.add(currentFile);
        command.add("--generated-file");
        command.add(generatedFile);
        command.add("--output-file");
        command.add(outputFile);
        
        // Executa o processo
        ProcessBuilder processBuilder = new ProcessBuilder(command);
        processBuilder.redirectErrorStream(true);
        
        Process process = processBuilder.start();
        
        // Captura a saída
        StringBuilder output = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(process.getInputStream()))) {
            String line;
            while ((line = reader.readLine()) != null) {
                output.append(line).append("\n");
            }
        }
        
        // Aguarda conclusão com timeout
        boolean finished = process.waitFor(timeoutSeconds, TimeUnit.SECONDS);
        
        if (!finished) {
            process.destroyForcibly();
            throw new IOException("Processo excedeu o timeout de " + timeoutSeconds + " segundos");
        }
        
        long executionTime = System.currentTimeMillis() - startTime;
        int exitCode = process.exitValue();
        
        return new MergeResult(
            exitCode == 0,
            exitCode,
            output.toString(),
            executionTime
        );
    }
    
    /**
     * Executa o merge com caminhos relativos ao diretório do projeto
     * 
     * @param projectRoot Raiz do projeto
     * @param currentFile Caminho relativo do arquivo atual
     * @param generatedFile Caminho relativo do arquivo gerado
     * @param outputFile Caminho relativo do arquivo de saída
     * @return Resultado do merge
     */
    public MergeResult mergeRelative(Path projectRoot, String currentFile, 
                                     String generatedFile, String outputFile) 
            throws IOException, InterruptedException {
        
        Path currentPath = projectRoot.resolve(currentFile);
        Path generatedPath = projectRoot.resolve(generatedFile);
        Path outputPath = projectRoot.resolve(outputFile);
        
        return merge(
            currentPath.toString(),
            generatedPath.toString(),
            outputPath.toString()
        );
    }
    
    /**
     * Resultado do merge
     */
    public static class MergeResult {
        private final boolean success;
        private final int exitCode;
        private final String output;
        private final long executionTime;
        
        public MergeResult(boolean success, int exitCode, String output, long executionTime) {
            this.success = success;
            this.exitCode = exitCode;
            this.output = output;
            this.executionTime = executionTime;
        }
        
        public boolean isSuccess() {
            return success;
        }
        
        public int getExitCode() {
            return exitCode;
        }
        
        public String getOutput() {
            return output;
        }
        
        public long getExecutionTime() {
            return executionTime;
        }
        
        @Override
        public String toString() {
            return String.format(
                "MergeResult{success=%s, exitCode=%d, executionTime=%dms}",
                success, exitCode, executionTime
            );
        }
    }
    
    /**
     * Exemplo de uso
     */
    public static void main(String[] args) {
        try {
            // Caminho para o executável (ajuste conforme necessário)
            String executablePath = "./dart-ast-merge";
            
            DartAstMerger merger = new DartAstMerger(executablePath);
            
            // Exemplo 1: Caminhos absolutos
            MergeResult result = merger.merge(
                "example/current_file.dart",
                "example/generated_file.dart",
                "example/merged_output.dart"
            );
            
            System.out.println("Status: " + (result.isSuccess() ? "✅ Sucesso" : "❌ Falha"));
            System.out.println("Tempo de execução: " + result.getExecutionTime() + "ms");
            System.out.println("Saída:\n" + result.getOutput());
            
            // Exemplo 2: Caminhos relativos
            Path projectRoot = Paths.get(System.getProperty("user.dir"));
            MergeResult result2 = merger.mergeRelative(
                projectRoot,
                "lib/widgets/my_widget.dart",
                "lib/widgets/my_widget.generated.dart",
                "lib/widgets/my_widget.merged.dart"
            );
            
            if (result2.isSuccess()) {
                System.out.println("Merge concluído com sucesso!");
            }
            
        } catch (Exception e) {
            System.err.println("Erro no merge: " + e.getMessage());
            e.printStackTrace();
        }
    }
}

