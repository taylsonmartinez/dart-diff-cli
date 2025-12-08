# 🚀 Setup GitHub Actions - Passo a Passo

## ✅ Você Está Aqui

```
✅ Git inicializado
✅ Arquivos commitados
⏳ Aguardando: Push para GitHub
```

## 📝 Próximos Passos

### 1️⃣ Criar Repositório no GitHub

1. **Abra seu navegador e vá para:**
   ```
   https://github.com/new
   ```

2. **Preencha:**
   - **Repository name:** `dart-ast-merge` (ou outro nome)
   - **Description:** `Dart AST Smart Merge CLI - Intelligent code merging for Java/Kotlin projects`
   - **Visibility:** 
     - ✅ **Public** (recomendado - GitHub Actions grátis)
     - 🟡 Private (só se tiver GitHub Pro - Actions tem limite)
   
3. **NÃO marque:**
   - ❌ Add a README file
   - ❌ Add .gitignore
   - ❌ Choose a license
   
   (Já temos tudo isso!)

4. **Clique:** `Create repository` (botão verde)

### 2️⃣ Copiar URL do Repositório

Após criar, você verá uma página com instruções. Copie a URL que aparece:

```
https://github.com/SEU-USUARIO/dart-ast-merge.git
```

**Exemplo:**
- Se seu usuário é `taylson`: `https://github.com/taylson/dart-ast-merge.git`

### 3️⃣ Executar Comandos no Terminal

Volte aqui e execute estes comandos:

```bash
cd /Users/taylson/developer/dart-diff-cli

# Adicione o remote (substitua SEU-USUARIO pelo seu usuário GitHub)
git remote add origin https://github.com/SEU-USUARIO/dart-ast-merge.git

# Faça push
git push -u origin main
```

**Exemplo real:**
```bash
# Se seu usuário for taylson:
git remote add origin https://github.com/taylson/dart-ast-merge.git
git push -u origin main
```

### 4️⃣ Aguardar GitHub Actions Compilar

1. **Vá para o repositório no navegador:**
   ```
   https://github.com/SEU-USUARIO/dart-ast-merge
   ```

2. **Clique na aba:** `Actions`

3. **Você verá:** Um workflow rodando com nome "Build Multi-Platform Binaries"
   - 🟡 Amarelo = Rodando
   - 🟢 Verde = Concluído
   - 🔴 Vermelho = Erro

4. **Aguarde ~5 minutos** ⏱️

### 5️⃣ Baixar os Binários Compilados

Quando o workflow ficar 🟢 verde:

1. **Clique no workflow** (linha com nome "Build Multi-Platform Binaries")

2. **Desça até a seção:** `Artifacts`

3. **Você verá 3 downloads:**
   - 📦 `dart-ast-merge-linux`
   - 📦 `dart-ast-merge-macos`
   - 📦 `dart-ast-merge-windows`

4. **Clique em cada um para baixar**

5. **Extraia os arquivos** (vêm em .zip)

6. **Copie para o projeto:**
   ```bash
   cd /Users/taylson/developer/dart-diff-cli
   mkdir -p dist
   
   # Copie os arquivos baixados:
   cp ~/Downloads/dart-ast-merge-linux dist/
   cp ~/Downloads/dart-ast-merge-macos dist/
   cp ~/Downloads/dart-ast-merge.exe dist/
   
   # Permissões (Mac/Linux)
   chmod +x dist/dart-ast-merge-*
   ```

### 6️⃣ Verificar

```bash
ls -lh dist/
# Deve mostrar:
# -rwxr-xr-x  7.8M  dart-ast-merge-linux
# -rwxr-xr-x  7.8M  dart-ast-merge-macos
# -rwxr-xr-x  7.8M  dart-ast-merge.exe
```

## 🎉 Pronto!

Agora você tem os 3 executáveis! ✅

---

## 🔄 Para Futuras Atualizações

Sempre que você fizer mudanças no código:

```bash
# 1. Faça suas alterações

# 2. Commit
git add .
git commit -m "Descrição das mudanças"

# 3. Push
git push

# 4. GitHub Actions recompila automaticamente!
# 5. Baixe novos artifacts em 5 minutos
```

---

## 🏷️ (Opcional) Criar Release

Para versões oficiais, use tags:

```bash
# Crie uma tag de versão
git tag v1.0.0

# Push da tag
git push origin v1.0.0

# GitHub Actions cria um Release automaticamente
# com os 3 binários já anexados!
```

Depois, vá em: `https://github.com/SEU-USUARIO/dart-ast-merge/releases`

Os binários estarão lá permanentemente! 🎁

---

## ❓ Troubleshooting

### Erro: "Permission denied" ao fazer push

**Solução:** Configure autenticação GitHub

```bash
# Opção 1: HTTPS (mais fácil)
# GitHub vai pedir usuário e token
# Token: https://github.com/settings/tokens

# Opção 2: SSH
# Configure SSH key: https://docs.github.com/en/authentication/connecting-to-github-with-ssh
```

### Erro no workflow

1. Vá em Actions
2. Clique no workflow com erro
3. Veja os logs
4. Geralmente é problema de sintaxe no código

### Não vejo a aba Actions

- Repositório privado sem GitHub Pro
- Actions desabilitado: Settings → Actions → Enable

---

## 📱 Comandos Resumidos

```bash
# Passo 1: Crie repo no GitHub (browser)

# Passo 2: Adicione remote e push
git remote add origin https://github.com/SEU-USUARIO/dart-ast-merge.git
git push -u origin main

# Passo 3: Aguarde 5 minutos

# Passo 4: Baixe artifacts (browser)

# Passo 5: Copie para dist/
cp ~/Downloads/dart-ast-merge-* dist/
chmod +x dist/dart-ast-merge-*

# ✅ Pronto!
```

---

## 🎯 Status Atual

- ✅ Código pronto
- ✅ Git configurado
- ✅ Commit feito
- ⏳ **VOCÊ ESTÁ AQUI:** Criar repo no GitHub
- ⏹️ Push para GitHub
- ⏹️ Aguardar compilação
- ⏹️ Baixar binários

**Próximo:** Abra https://github.com/new no navegador! 🚀

