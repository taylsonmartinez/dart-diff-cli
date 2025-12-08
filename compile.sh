#!/bin/bash
# Script para compilar o Dart CLI para executável nativo

echo "🔨 Compilando Dart AST Merge CLI para executável nativo..."

# Compila para o executável nativo
dart compile exe bin/main.dart -o dart-ast-merge

echo "✅ Compilação concluída!"
echo "📦 Executável criado: dart-ast-merge"
echo ""
echo "Teste o executável:"
echo "./dart-ast-merge --help"
echo ""
echo "Tamanho do arquivo:"
ls -lh dart-ast-merge

