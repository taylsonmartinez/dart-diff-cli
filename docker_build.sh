#!/bin/bash

# Script para compilar usando Docker (para Linux)
# Útil quando você está no Mac/Windows mas quer compilar para Linux

set -e

echo "🐳 Compilando para Linux usando Docker..."
echo ""

# Cria Dockerfile temporário se não existir
if [ ! -f "Dockerfile.build" ]; then
    cat > Dockerfile.build << 'EOF'
FROM dart:stable

WORKDIR /app

# Copia arquivos do projeto
COPY pubspec.yaml .
COPY bin/ bin/
COPY lib/ lib/

# Instala dependências
RUN dart pub get

# Compila
RUN dart compile exe bin/main.dart -o dart-ast-merge-linux

CMD ["echo", "Build completed"]
EOF
fi

# Compila usando Docker
echo "📦 Criando imagem Docker..."
docker build -f Dockerfile.build -t dart-ast-merge-builder .

echo ""
echo "🔨 Compilando binário..."
docker create --name dart-ast-merge-temp dart-ast-merge-builder

echo ""
echo "📤 Extraindo binário..."
mkdir -p dist
docker cp dart-ast-merge-temp:/app/dart-ast-merge-linux ./dist/

echo ""
echo "🧹 Limpando..."
docker rm dart-ast-merge-temp

echo ""
echo "✅ Compilação concluída!"
echo "📦 Binário Linux: dist/dart-ast-merge-linux"
ls -lh dist/dart-ast-merge-linux

chmod +x dist/dart-ast-merge-linux

echo ""
echo "🧪 Testando binário (se estiver no Linux)..."
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    ./dist/dart-ast-merge-linux --help
else
    echo "⚠️  Você não está no Linux, não é possível testar o binário aqui."
    echo "   Transfira para uma máquina Linux para testar."
fi

