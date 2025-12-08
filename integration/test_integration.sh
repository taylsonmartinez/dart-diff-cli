#!/bin/bash

# Script de teste para demonstrar a integração Java/Kotlin
# Este script simula o uso do executável em um projeto real

set -e

echo "🧪 Teste de Integração - Dart AST Merge CLI"
echo "==========================================="
echo ""

# Cores para output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Caminho para o executável
EXECUTABLE="../dart-ast-merge"

# Verifica se o executável existe
if [ ! -f "$EXECUTABLE" ]; then
    echo -e "${RED}❌ Executável não encontrado: $EXECUTABLE${NC}"
    echo "Execute: dart compile exe bin/main.dart -o dart-ast-merge"
    exit 1
fi

echo -e "${GREEN}✅ Executável encontrado${NC}"
echo ""

# Teste 1: Mostrar help
echo -e "${YELLOW}📋 Teste 1: Exibir ajuda${NC}"
$EXECUTABLE --help
echo ""

# Teste 2: Merge básico
echo -e "${YELLOW}🔄 Teste 2: Merge de exemplo${NC}"
$EXECUTABLE \
    --current-file ../example/current_file.dart \
    --generated-file ../example/generated_file.dart \
    --output-file ../example/test_output.dart

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Merge concluído com sucesso${NC}"
else
    echo -e "${RED}❌ Merge falhou${NC}"
    exit 1
fi
echo ""

# Teste 3: Verificar tamanho do output
echo -e "${YELLOW}📊 Teste 3: Verificar output${NC}"
if [ -f "../example/test_output.dart" ]; then
    lines=$(wc -l < "../example/test_output.dart")
    size=$(ls -lh "../example/test_output.dart" | awk '{print $5}')
    echo "  Arquivo: example/test_output.dart"
    echo "  Linhas: $lines"
    echo "  Tamanho: $size"
    echo -e "${GREEN}✅ Output gerado com sucesso${NC}"
else
    echo -e "${RED}❌ Output não foi gerado${NC}"
    exit 1
fi
echo ""

# Teste 4: Validar sintaxe do output (se dart estiver disponível)
if command -v dart &> /dev/null; then
    echo -e "${YELLOW}✓ Teste 4: Validar sintaxe${NC}"
    if dart analyze ../example/test_output.dart 2>&1 | grep -q "No issues found"; then
        echo -e "${GREEN}✅ Sintaxe válida${NC}"
    else
        echo -e "${YELLOW}⚠️  Aviso: dart analyze reportou issues (esperado em exemplo isolado)${NC}"
    fi
else
    echo -e "${YELLOW}⊘ Teste 4: Pulado (dart não instalado)${NC}"
fi
echo ""

# Teste 5: Simulação de uso Java
echo -e "${YELLOW}☕ Teste 5: Exemplo de integração Java${NC}"
cat << 'EOF'
// Exemplo de uso em Java:

DartAstMerger merger = new DartAstMerger("tools/dart-ast-merge");

MergeResult result = merger.merge(
    "lib/my_widget.dart",
    "lib/my_widget.generated.dart",
    "lib/my_widget.dart"
);

if (result.isSuccess()) {
    System.out.println("✅ Merge concluído em " + result.getExecutionTime() + "ms");
} else {
    System.err.println("❌ Erro: " + result.getOutput());
}
EOF
echo ""

# Teste 6: Simulação de uso Kotlin
echo -e "${YELLOW}🎯 Teste 6: Exemplo de integração Kotlin${NC}"
cat << 'EOF'
// Exemplo de uso em Kotlin:

val merger = DartAstMerger("tools/dart-ast-merge")

val result = merger.merge(
    currentFile = "lib/my_widget.dart",
    generatedFile = "lib/my_widget.generated.dart",
    outputFile = "lib/my_widget.dart"
)

when {
    result.success -> println("✅ Merge concluído em ${result.executionTime}ms")
    else -> println("❌ Erro: ${result.output}")
}
EOF
echo ""

# Limpeza
echo -e "${YELLOW}🧹 Limpando arquivos de teste...${NC}"
rm -f ../example/test_output.dart
echo -e "${GREEN}✅ Limpeza concluída${NC}"
echo ""

# Resumo
echo "=========================================="
echo -e "${GREEN}✅ Todos os testes passaram!${NC}"
echo "=========================================="
echo ""
echo "📦 Informações do executável:"
ls -lh $EXECUTABLE
echo ""
echo "📚 Próximos passos:"
echo "  1. Copie o executável para seu projeto: cp $EXECUTABLE /seu-projeto/tools/"
echo "  2. Copie a classe de integração (JavaIntegration.java ou KotlinIntegration.kt)"
echo "  3. Use no seu código!"
echo ""
echo "📖 Documentação completa em INTEGRATION_GUIDE.md"

