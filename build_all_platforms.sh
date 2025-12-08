#!/bin/bash

# Script para compilar o Dart AST Merge CLI para múltiplas plataformas
# 
# LIMITAÇÃO: Dart só pode compilar nativamente para o SO atual
# 
# Soluções:
# 1. Execute este script em cada SO (Mac, Linux, Windows)
# 2. Use GitHub Actions (recomendado - veja build_with_github_actions.yml)
# 3. Use Docker (veja instruções abaixo)

set -e

echo "🔨 Dart AST Merge CLI - Multi-Platform Build"
echo "=============================================="
echo ""

# Detecta o SO atual
OS="$(uname -s)"
case "${OS}" in
    Linux*)     CURRENT_OS=Linux;;
    Darwin*)    CURRENT_OS=macOS;;
    MINGW*|MSYS*|CYGWIN*)  CURRENT_OS=Windows;;
    *)          CURRENT_OS="Unknown";;
esac

echo "🖥️  Sistema Operacional detectado: $CURRENT_OS"
echo ""

# Cria diretório de distribuição
DIST_DIR="dist"
mkdir -p "$DIST_DIR"

echo "📦 Compilando para $CURRENT_OS..."
echo ""

# Compila para o SO atual
case "${CURRENT_OS}" in
    macOS)
        echo "🍎 Compilando para macOS..."
        dart compile exe bin/main.dart -o "$DIST_DIR/dart-ast-merge-macos"
        chmod +x "$DIST_DIR/dart-ast-merge-macos"
        
        # Verifica se consegue cross-compile (não funciona normalmente)
        echo ""
        echo "⚠️  NOTA: Dart não suporta cross-compilation nativa."
        echo "   Para compilar para Linux e Windows, você precisa:"
        echo ""
        echo "   Opção 1 - GitHub Actions (Recomendado):"
        echo "   - Use o workflow em .github/workflows/build.yml"
        echo "   - Commit e push: git push origin main"
        echo "   - Baixe os binários em GitHub Releases"
        echo ""
        echo "   Opção 2 - Máquinas Virtuais:"
        echo "   - Linux: Execute este script em uma VM/Container Linux"
        echo "   - Windows: Execute compile_windows.bat em uma VM Windows"
        echo ""
        echo "   Opção 3 - Docker:"
        echo "   - Use docker_build.sh para compilar Linux"
        ;;
        
    Linux)
        echo "🐧 Compilando para Linux..."
        dart compile exe bin/main.dart -o "$DIST_DIR/dart-ast-merge-linux"
        chmod +x "$DIST_DIR/dart-ast-merge-linux"
        
        echo ""
        echo "⚠️  Para compilar para macOS e Windows:"
        echo "   - Execute este script em macOS"
        echo "   - Execute compile_windows.bat no Windows"
        echo "   - Ou use GitHub Actions (recomendado)"
        ;;
        
    Windows)
        echo "🪟 Compilando para Windows..."
        dart compile exe bin/main.dart -o "$DIST_DIR/dart-ast-merge.exe"
        
        echo ""
        echo "⚠️  Para compilar para macOS e Linux:"
        echo "   - Execute build_all_platforms.sh em macOS/Linux"
        echo "   - Ou use GitHub Actions (recomendado)"
        ;;
        
    *)
        echo "❌ Sistema operacional não suportado: $CURRENT_OS"
        exit 1
        ;;
esac

echo ""
echo "✅ Compilação concluída!"
echo ""
echo "📂 Binários gerados em: $DIST_DIR/"
ls -lh "$DIST_DIR/"

echo ""
echo "📝 Próximos passos:"
echo "   1. Para compilar para TODAS as plataformas, use GitHub Actions"
echo "   2. Veja: .github/workflows/build.yml"
echo "   3. Ou compile manualmente em cada SO"
echo ""
echo "🚀 Para distribuir:"
echo "   - Copie os binários de $DIST_DIR/ para seu projeto"
echo "   - Instrua usuários a usarem o binário correto para seu SO"

