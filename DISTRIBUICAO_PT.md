# 📦 Guia de Distribuição - Português

## 🎯 Como Gerar Executáveis para Todas as Plataformas

### ⚠️ Informação Importante

**Dart só compila nativamente para o sistema operacional em que você está executando.**

- Você está no **macOS** ✅
- Pode compilar direto para **macOS** ✅  
- Para **Linux** e **Windows**, precisa usar uma das soluções abaixo ⬇️

---

## 🚀 Solução 1: GitHub Actions (MAIS FÁCIL!) ⭐

**Recomendado!** Compila automaticamente para macOS, Linux E Windows de uma vez!

### Como Fazer:

#### 1. Crie um repositório no GitHub

```bash
# No terminal, dentro do projeto:
cd /Users/taylson/developer/dart-diff-cli

# Se ainda não iniciou o git:
git init
git add .
git commit -m "Dart AST Merge CLI - Versão inicial"

# Crie um repositório no GitHub (https://github.com/new)
# Depois:
git remote add origin https://github.com/SEU-USUARIO/SEU-REPO.git
git branch -M main
git push -u origin main
```

#### 2. GitHub Actions Compila Automaticamente!

- O arquivo `.github/workflows/build.yml` já está configurado ✅
- Quando você fizer push, GitHub Actions compila para as 3 plataformas
- Aguarde ~5 minutos

#### 3. Baixe os Binários

**Opção A - Via Actions (qualquer commit):**
1. Vá em: `https://github.com/SEU-USUARIO/SEU-REPO/actions`
2. Clique no workflow mais recente
3. Baixe os "Artifacts":
   - `dart-ast-merge-macos`
   - `dart-ast-merge-linux`  
   - `dart-ast-merge.exe`

**Opção B - Via Release (versão oficial):**
```bash
# Crie uma tag de versão:
git tag v1.0.0
git push origin v1.0.0

# GitHub cria automaticamente um Release com os 3 binários!
```

### ✅ Resultado:
```
✅ dart-ast-merge-macos   (7.8 MB)
✅ dart-ast-merge-linux   (7.8 MB)
✅ dart-ast-merge.exe     (7.8 MB)
```

**Pronto! Você tem os 3 executáveis!** 🎉

---

## 🖥️ Solução 2: Compilar Manualmente (Você Controla)

Se você tem acesso a máquinas com cada sistema operacional:

### No Mac (você está aqui):
```bash
cd /Users/taylson/developer/dart-diff-cli
./build_all_platforms.sh
```

**Resultado:** `dist/dart-ast-merge-macos` ✅

### No Linux (precisa de uma máquina Linux):
```bash
git clone https://github.com/SEU-USUARIO/SEU-REPO.git
cd dart-diff-cli
./build_all_platforms.sh
```

**Resultado:** `dist/dart-ast-merge-linux` ✅

### No Windows (precisa de uma máquina Windows):
```cmd
git clone https://github.com/SEU-USUARIO/SEU-REPO.git
cd dart-diff-cli
compile_windows.bat
```

**Resultado:** `dist\dart-ast-merge.exe` ✅

---

## 🐳 Solução 3: Docker (Para Compilar Linux no Mac)

Se você quer compilar para Linux mas está no Mac:

```bash
cd /Users/taylson/developer/dart-diff-cli
./docker_build.sh
```

**Requisito:** Docker instalado e rodando

**Resultado:** `dist/dart-ast-merge-linux` ✅

---

## 📊 Comparação das Soluções

| Solução | Facilidade | Você tem? | Gera 3 binários? |
|---------|-----------|-----------|------------------|
| **GitHub Actions** | ⭐⭐⭐⭐⭐ Muito fácil | ✅ Sim | ✅ Sim! |
| **Manual** | ⭐⭐ Trabalhoso | ❌ Precisa 3 SOs | ✅ Sim |
| **Docker** | ⭐⭐⭐⭐ Fácil | Se tem Docker | 🟡 Só Linux |

**Recomendação:** Use **GitHub Actions**! É automático e gera os 3! 🎯

---

## 🎁 O Que Você Já Tem Agora

Você acabou de compilar para **macOS**:

```bash
ls -lh dist/
# -rwxr-xr-x  7.8M  dart-ast-merge-macos
```

**Para ter os outros 2 (Linux e Windows):**
- Use GitHub Actions (recomendado)
- Ou compile manualmente em cada SO

---

## 📦 Como Distribuir os 3 Binários

### Estrutura Recomendada no Seu Projeto Java/Kotlin:

```
seu-projeto/
├── src/
├── lib/
└── tools/
    ├── dart-ast-merge-macos      # Para Mac
    ├── dart-ast-merge-linux      # Para Linux
    └── dart-ast-merge.exe        # Para Windows
```

### Código para Detectar SO Automaticamente:

```kotlin
// Kotlin
val os = System.getProperty("os.name").lowercase()
val executable = when {
    os.contains("windows") -> "tools/dart-ast-merge.exe"
    os.contains("mac") -> "tools/dart-ast-merge-macos"
    else -> "tools/dart-ast-merge-linux"
}

val merger = DartAstMerger(executable)
```

```java
// Java
String os = System.getProperty("os.name").toLowerCase();
String executable;

if (os.contains("windows")) {
    executable = "tools/dart-ast-merge.exe";
} else if (os.contains("mac")) {
    executable = "tools/dart-ast-merge-macos";
} else {
    executable = "tools/dart-ast-merge-linux";
}

DartAstMerger merger = new DartAstMerger(executable);
```

---

## 🚀 Passo a Passo Completo (Recomendado)

### 1️⃣ Crie Repositório no GitHub

```bash
# Inicialize git (se ainda não fez)
cd /Users/taylson/developer/dart-diff-cli
git init
git add .
git commit -m "Initial release"

# Crie repo no GitHub: https://github.com/new
# Depois:
git remote add origin https://github.com/SEU-USUARIO/dart-ast-merge.git
git push -u origin main
```

### 2️⃣ GitHub Actions Compila Automaticamente

- Vá em: Actions → Veja o workflow rodando
- Aguarde ~5 minutos

### 3️⃣ Crie um Release

```bash
git tag v1.0.0
git push origin v1.0.0
```

### 4️⃣ Baixe os 3 Binários

- Vá em: Releases → v1.0.0
- Baixe:
  - `dart-ast-merge-macos`
  - `dart-ast-merge-linux`
  - `dart-ast-merge.exe`

### 5️⃣ Copie para Seu Projeto

```bash
cp dist/dart-ast-merge-* /caminho/seu-projeto-java/tools/
```

### 6️⃣ Use no Código!

```kotlin
val merger = DartAstMerger("tools/dart-ast-merge-macos")
val result = merger.merge("current.dart", "generated.dart", "output.dart")
println("✅ Merge: ${result.success}")
```

---

## 🧪 Testando os Binários

### macOS (você já tem):
```bash
./dist/dart-ast-merge-macos --help
./dist/dart-ast-merge-macos \
  -c example/current_file.dart \
  -g example/generated_file.dart \
  -o test.dart
```

### Linux (após compilar):
```bash
chmod +x dart-ast-merge-linux
./dart-ast-merge-linux --help
```

### Windows (após compilar):
```cmd
dart-ast-merge.exe --help
```

---

## 📋 Checklist Completo

- [x] ✅ Compilado para macOS (`dist/dart-ast-merge-macos`)
- [ ] ⬜ Criou repositório no GitHub
- [ ] ⬜ GitHub Actions compilou Linux e Windows
- [ ] ⬜ Baixou os 3 binários
- [ ] ⬜ Copiou para projeto Java/Kotlin
- [ ] ⬜ Testou no código
- [ ] ⬜ Distribuiu para usuários

---

## ❓ Dúvidas Frequentes

### P: Preciso compilar manualmente para cada SO?
**R:** Não! Use GitHub Actions que faz tudo automaticamente.

### P: Posso compilar Windows no Mac?
**R:** Não nativamente. Use GitHub Actions ou máquina Windows.

### P: GitHub Actions é pago?
**R:** Não! É gratuito para repositórios públicos (2000 min/mês).

### P: Como atualizo os binários?
**R:** Faça commit + push. GitHub Actions recompila automaticamente.

### P: Posso usar sem Git/GitHub?
**R:** Sim, mas precisa compilar manualmente em cada SO.

---

## 🎯 Resumo

### O Que Você Tem Agora:
- ✅ Executável macOS compilado
- ✅ Scripts prontos para Linux e Windows
- ✅ GitHub Actions configurado
- ✅ Documentação completa

### Para Ter os 3 Binários:

**Opção Fácil (5 minutos):**
1. Push para GitHub
2. Aguarde Actions compilar
3. Baixe os 3 binários
4. ✅ Pronto!

**Opção Manual (30-60 minutos):**
1. Compile no Mac ✅ (já feito!)
2. Compile no Linux (precisa máquina)
3. Compile no Windows (precisa máquina)
4. ✅ Pronto!

---

## 🎉 Conclusão

**Recomendação final:** Use **GitHub Actions**! 

É:
- ✅ Automático
- ✅ Rápido (~5 min)
- ✅ Gratuito
- ✅ Gera os 3 binários
- ✅ Sempre atualizado

**Próximo passo:**
```bash
git init
git add .
git commit -m "Release"
# Crie repo no GitHub e push!
```

---

**Dúvidas?** Veja [BUILD_GUIDE.md](BUILD_GUIDE.md) para mais detalhes! 📚

