@echo off
REM Script para compilar no Windows
REM Execute este arquivo em uma máquina Windows com Dart instalado

echo 🔨 Compilando Dart AST Merge CLI para Windows...
echo.

REM Cria diretório de distribuição
if not exist dist mkdir dist

REM Compila para Windows
dart compile exe bin/main.dart -o dist/dart-ast-merge.exe

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ Compilação concluída!
    echo.
    echo 📦 Executável gerado: dist/dart-ast-merge.exe
    dir dist\dart-ast-merge.exe
    echo.
    echo 🚀 Para usar:
    echo    .\dist\dart-ast-merge.exe --help
) else (
    echo.
    echo ❌ Erro na compilação
    exit /b 1
)

pause

