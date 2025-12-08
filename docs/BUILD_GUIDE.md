# 🔨 Guia de Build Multi-Plataforma

## 📋 Resumo

Este guia mostra como compilar o **Dart AST Merge CLI** para as 3 plataformas principais: **macOS, Linux e Windows**.

## ⚠️ Limitação Importante

**Dart só pode compilar nativamente para o sistema operacional em que está executando.**

Isso significa:
- 🍎 No **macOS** → compila para macOS
- 🐧 No **Linux** → compila para Linux  
- 🪟 No **Windows** → compila para Windows

**Não existe cross-compilation nativa no Dart.**

## 🎯 Soluções para Compilar Todas as Plataformas

### ✅ Opção 1: GitHub Actions (Recomendado)

**Melhor opção!** Compila automaticamente para as 3 plataformas usando CI/CD.

#### Passo a Passo:

1. **Inicialize Git (se ainda não fez):**
```bash
cd /Users/taylson/developer/dart-diff-cli
git init
git add .
git commit -m "Initial commit: Dart AST Merge CLI"
```

2. **Crie repositório no GitHub:**
- Vá para https://github.com/new
- Crie um repositório (ex: `dart-ast-merge`)
- NÃO adicione README, .gitignore ou license

3. **Push para GitHub:**
```bash
git remote add origin https://github.com/SEU-USUARIO/dart-ast-merge.git
git branch -M main
git push -u origin main
```

4. **GitHub Actions vai rodar automaticamente!**
- Acesse: `https://github.com/SEU-USUARIO/dart-ast-merge/actions`
- Aguarde o build terminar (~5 minutos)
- Baixe os binários em "Artifacts"

5. **Para criar um Release (opcional):**
```bash
# Crie uma tag de versão
git tag v1.0.0
git push origin v1.0.0

# GitHub Actions vai criar um Release automaticamente
# com os 3 binários anexados!
```

**Resultado:**
```
✅ dart-ast-merge-macos   (para macOS)
✅ dart-ast-merge-linux   (para Linux)
✅ dart-ast-merge.exe     (para Windows)
```

---

### 🖥️ Opção 2: Build Manual em Cada SO

Se você tem acesso a máquinas/VMs com cada sistema operacional:

#### No macOS:
```bash
./build_all_platforms.sh
# Gera: dist/dart-ast-merge-macos
```

#### No Linux:
```bash
./build_all_platforms.sh
# Gera: dist/dart-ast-merge-linux
```

#### No Windows:
```cmd
compile_windows.bat
REM Gera: dist\dart-ast-merge.exe
```

---

### 🐳 Opção 3: Docker (Para Linux)

Se você está no Mac/Windows mas quer compilar para Linux:

```bash
./docker_build.sh
# Gera: dist/dart-ast-merge-linux
```

**Requisitos:**
- Docker instalado
- Docker daemon rodando

---

## 📦 Estrutura dos Binários

Após compilar para todas as plataformas:

```
dist/
├── dart-ast-merge-macos    # macOS (ARM64 ou x86_64)
├── dart-ast-merge-linux    # Linux (x86_64)
└── dart-ast-merge.exe      # Windows (x86_64)
```

## 🚀 Como Distribuir

### 1. Detectar SO Automaticamente (Java/Kotlin)

```kotlin
val os = System.getProperty("os.name").lowercase()
val executable = when {
    os.contains("windows") -> "tools/dart-ast-merge.exe"
    os.contains("mac") -> "tools/dart-ast-merge-macos"
    else -> "tools/dart-ast-merge-linux"
}

val merger = DartAstMerger(executable)
```

### 2. Estrutura no Projeto

```
seu-projeto/
└── tools/
    ├── dart-ast-merge-macos
    ├── dart-ast-merge-linux
    └── dart-ast-merge.exe
```

### 3. Documentação para Usuários

```markdown
## Instalação

1. Baixe o binário correto para seu sistema:
   - macOS: `dart-ast-merge-macos`
   - Linux: `dart-ast-merge-linux`
   - Windows: `dart-ast-merge.exe`

2. Torne executável (Mac/Linux):
   ```bash
   chmod +x dart-ast-merge-*
   ```

3. Use:
   ```bash
   ./dart-ast-merge-macos --help
   ```
```

---

## 📊 Comparação das Opções

| Opção | Facilidade | Tempo | Requer |
|-------|-----------|-------|--------|
| **GitHub Actions** | ⭐⭐⭐⭐⭐ | ~5 min | Conta GitHub |
| **Build Manual** | ⭐⭐ | ~30 min | Acesso a 3 SOs |
| **Docker (Linux)** | ⭐⭐⭐⭐ | ~10 min | Docker |

**Recomendação:** Use **GitHub Actions** - é automático e gratuito! 🎉

---

## 🧪 Testando os Binários

### macOS:
```bash
./dist/dart-ast-merge-macos --help
./dist/dart-ast-merge-macos \
  -c example/current_file.dart \
  -g example/generated_file.dart \
  -o test_output.dart
```

### Linux:
```bash
chmod +x dist/dart-ast-merge-linux
./dist/dart-ast-merge-linux --help
```

### Windows:
```cmd
dist\dart-ast-merge.exe --help
```

---

## 📝 Scripts Disponíveis

| Script | Descrição | SO |
|--------|-----------|-----|
| `build_all_platforms.sh` | Build principal | macOS/Linux |
| `compile_windows.bat` | Build para Windows | Windows |
| `docker_build.sh` | Build Linux via Docker | Qualquer |
| `.github/workflows/build.yml` | CI/CD automático | Qualquer |

---

## 🎯 Workflow Recomendado

### Para Desenvolvimento:
```bash
# Compile para seu SO atual
./build_all_platforms.sh

# Teste localmente
./dist/dart-ast-merge-macos -c current.dart -g generated.dart -o output.dart
```

### Para Release:
```bash
# 1. Commit suas mudanças
git add .
git commit -m "Release v1.0.0"

# 2. Crie tag
git tag v1.0.0

# 3. Push
git push origin main --tags

# 4. GitHub Actions compila tudo automaticamente!
# 5. Baixe os binários em GitHub Releases
```

---

## 🔧 Personalização

### Alterar Nome do Binário

Em `.github/workflows/build.yml`:
```yaml
output-name: meu-app-macos  # Altere aqui
```

### Adicionar Mais Plataformas

```yaml
matrix:
  os: [ubuntu-latest, macos-latest, windows-latest, macos-13]  # macOS Intel
  include:
    - os: macos-13
      output-name: dart-ast-merge-macos-intel
      artifact-name: macos-intel
```

---

## ❓ FAQ

### P: Por que não posso compilar para Windows no Mac?
**R:** Dart não suporta cross-compilation nativa. Use GitHub Actions ou uma VM Windows.

### P: Os binários são grandes?
**R:** Sim, ~7-10 MB cada. Isso é normal para executáveis Dart nativos (incluem a VM Dart).

### P: Posso reduzir o tamanho?
**R:** Sim, use: `dart compile exe --target-os=<os> bin/main.dart` mas funcionalidade limitada.

### P: GitHub Actions é gratuito?
**R:** Sim! 2000 minutos/mês grátis em repositórios públicos. Suficiente para muitos builds.

### P: Como faço para distribuir os 3 binários?
**R:** 
- Opção 1: Inclua todos os 3 no seu projeto e detecte o SO em runtime
- Opção 2: Distribua via GitHub Releases (usuário baixa o correto)
- Opção 3: Crie instaladores específicos por plataforma

---

## 🎉 Pronto!

Você agora tem várias formas de compilar para as 3 plataformas:

1. ✅ **GitHub Actions** - Automático e fácil
2. ✅ **Build Manual** - Controle total
3. ✅ **Docker** - Para Linux sem VM

**Escolha a que melhor se adapta ao seu workflow!**

---

## 📚 Recursos

- [Dart Compile Documentation](https://dart.dev/tools/dart-compile)
- [GitHub Actions Documentation](https://docs.github.com/actions)
- [Docker Dart Images](https://hub.docker.com/_/dart)

---

**Dúvidas?** Abra uma issue no repositório! 🚀

