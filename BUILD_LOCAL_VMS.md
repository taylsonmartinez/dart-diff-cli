# 🖥️ Compilar com Máquinas Virtuais Locais

Como você não quer usar Docker ou CI/CD, esta é sua única opção para gerar todos os binários localmente.

## 🎯 Pré-requisitos

1. **Espaço em disco:** ~40 GB livres
2. **RAM:** Pelo menos 8 GB (16 GB recomendado)
3. **Software de virtualização:**
   - UTM (gratuito, para Mac M1/M2): https://mac.getutm.app/
   - VirtualBox (gratuito): https://www.virtualbox.org/
   - VMware Fusion Player (gratuito): https://www.vmware.com/products/fusion.html
   - Parallels Desktop (pago): https://www.parallels.com/

## 📦 Passo a Passo

### 1️⃣ Compilar para Linux (VM Ubuntu)

#### A. Criar VM Ubuntu

1. **Baixar Ubuntu:**
   - https://ubuntu.com/download/desktop
   - Recomendo: Ubuntu 22.04 LTS (ISO ~4 GB)

2. **Criar VM:**
   - UTM/VirtualBox: Novo → Linux → Ubuntu
   - RAM: 4 GB mínimo
   - Disco: 25 GB

3. **Instalar Ubuntu na VM**

#### B. Instalar Dart na VM Ubuntu

```bash
# Na VM Ubuntu, abra o terminal:

# 1. Adicionar repositório Dart
sudo apt-get update
sudo apt-get install apt-transport-https
wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/dart.gpg
echo 'deb [signed-by=/usr/share/keyrings/dart.gpg arch=amd64] https://storage.googleapis.com/download.dartlang.org/linux/debian stable main' | sudo tee /etc/apt/sources.list.d/dart_stable.list

# 2. Instalar Dart
sudo apt-get update
sudo apt-get install dart

# 3. Adicionar ao PATH
echo 'export PATH="$PATH:/usr/lib/dart/bin"' >> ~/.bashrc
source ~/.bashrc

# 4. Verificar
dart --version
```

#### C. Transferir Projeto e Compilar

```bash
# Opção 1: Compartilhar pasta (mais fácil)
# Configure shared folder no UTM/VirtualBox
# A pasta do projeto fica acessível na VM

# Opção 2: Git (se tiver repositório)
git clone https://github.com/SEU-USUARIO/dart-diff-cli.git
cd dart-diff-cli

# Opção 3: Copiar manualmente via SCP/SFTP

# Compilar
dart pub get
dart compile exe bin/main.dart -o dart-ast-merge-linux

# Copiar de volta para Mac
# Via shared folder ou:
# scp dart-ast-merge-linux seu-usuario-mac@ip-do-mac:~/Downloads/
```

#### D. Copiar para dist/

```bash
# No Mac:
cp ~/Downloads/dart-ast-merge-linux /Users/taylson/developer/dart-diff-cli/dist/
chmod +x /Users/taylson/developer/dart-diff-cli/dist/dart-ast-merge-linux
```

---

### 2️⃣ Compilar para Windows (VM Windows)

#### A. Criar VM Windows

1. **Baixar Windows:**
   - Windows 11 Development Environment (gratuito, 90 dias)
   - https://developer.microsoft.com/en-us/windows/downloads/virtual-machines/
   - Ou: Windows ISO (se tiver licença)

2. **Criar VM:**
   - UTM/VirtualBox/Parallels: Novo → Windows
   - RAM: 4 GB mínimo
   - Disco: 60 GB

3. **Instalar Windows na VM**

#### B. Instalar Dart na VM Windows

1. **Baixar Dart SDK:**
   - https://dart.dev/get-dart
   - Ou via Chocolatey:
   ```powershell
   # No PowerShell (Admin):
   choco install dart-sdk
   ```

2. **Verificar:**
   ```powershell
   dart --version
   ```

#### C. Transferir Projeto e Compilar

```powershell
# Opção 1: Shared folder
# Configure no UTM/VirtualBox

# Opção 2: Git
git clone https://github.com/SEU-USUARIO/dart-diff-cli.git
cd dart-diff-cli

# Opção 3: Copiar arquivos manualmente

# Compilar
dart pub get
dart compile exe bin\main.dart -o dart-ast-merge.exe

# Copiar para Mac via shared folder ou rede
```

#### D. Copiar para dist/

```bash
# No Mac:
cp /caminho/shared/dart-ast-merge.exe /Users/taylson/developer/dart-diff-cli/dist/
```

---

## ⚡ Alternativa: Usar VMs Pré-configuradas

### Multipass (mais fácil para Linux)

```bash
# No Mac, instale Multipass:
brew install multipass

# Crie VM Ubuntu:
multipass launch --name dart-build --mem 4G --disk 20G

# Entre na VM:
multipass shell dart-build

# Instale Dart e compile (comandos acima)

# Copie arquivo:
multipass transfer dart-build:/caminho/dart-ast-merge-linux ./dist/
```

---

## 📊 Resumo dos Recursos Necessários

| VM | Sistema | RAM | Disco | Tempo Setup |
|----|---------|-----|-------|-------------|
| **Linux** | Ubuntu 22.04 | 4 GB | 25 GB | ~20 min |
| **Windows** | Win 11 Dev | 4 GB | 60 GB | ~30 min |

**Total:** 8 GB RAM, 85 GB disco (se rodar as 2 simultaneamente)

---

## 🎯 Workflow Recomendado

### Setup Inicial (uma vez):

1. ✅ Criar VM Linux (20 min)
2. ✅ Instalar Dart no Linux (5 min)
3. ✅ Criar VM Windows (30 min)
4. ✅ Instalar Dart no Windows (10 min)

### Compilação (sempre que atualizar):

1. ✅ Mac: `./build_all_platforms.sh` (10 seg)
2. ✅ Iniciar VM Linux (30 seg)
3. ✅ Compilar no Linux (10 seg)
4. ✅ Copiar binário Linux (5 seg)
5. ✅ Iniciar VM Windows (1 min)
6. ✅ Compilar no Windows (15 seg)
7. ✅ Copiar binário Windows (5 seg)

**Total por build:** ~3-5 minutos (após setup inicial)

---

## 💡 Dicas

### Para Linux (mais rápido):
- Use Multipass (mais leve que VirtualBox)
- Ou use WSL2 se tiver Windows em Parallels

### Para Windows:
- Use Windows Dev VM (gratuito, já configurado)
- Ou use Wine/CrossOver (não recomendado, pode ter bugs)

### Automatização:
```bash
# Script para compilar tudo:
# build_all_local.sh

#!/bin/bash

# 1. Mac
./build_all_platforms.sh

# 2. Linux (via Multipass)
multipass exec dart-build -- bash -c "cd /shared/dart-diff-cli && dart compile exe bin/main.dart -o dart-ast-merge-linux"
multipass transfer dart-build:/shared/dart-diff-cli/dart-ast-merge-linux ./dist/

# 3. Windows (via SSH ou shared folder)
# Precisa configurar SSH na VM Windows primeiro
scp compile_windows.bat windows-vm:/Users/Public/
ssh windows-vm "cd /Users/Public && compile_windows.bat"
scp windows-vm:/Users/Public/dist/dart-ast-merge.exe ./dist/
```

---

## ❓ FAQ

### P: Posso evitar VMs?
**R:** Não, sem Docker/CI/CD. Dart não faz cross-compilation.

### P: E se eu usar emuladores?
**R:** VMs são emuladores. QEMU, UTM, etc. são todos virtualizadores.

### P: Wine funciona?
**R:** Não recomendado. Dart precisa de APIs nativas do SO.

### P: Qual a VM mais leve?
**R:** Para Linux: Multipass. Para Windows: Windows Dev Environment.

### P: Preciso de licença Windows?
**R:** Não, use Windows Dev VM (gratuito por 90 dias, renovável).

---

## 🎉 Resultado Final

Após setup e compilação:

```bash
ls -lh dist/
# -rwxr-xr-x  7.8M  dart-ast-merge-macos    ✅
# -rwxr-xr-x  7.8M  dart-ast-merge-linux    ✅
# -rwxr-xr-x  7.8M  dart-ast-merge.exe      ✅
```

---

## 🚨 Importante

**Essa é a ÚNICA forma de compilar para todas as plataformas localmente sem Docker ou CI/CD.**

Se isso parece trabalhoso, reconsidere:
- **GitHub Actions:** Automático, gratuito, 5 minutos
- **Docker:** Mais leve que VMs, só para Linux

Mas se você realmente não pode usar essas opções, VMs são sua única alternativa.

