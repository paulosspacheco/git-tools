# git-generator-lcl.sh

Gera arquivos de integração Git para projetos Lazarus/FPC. Para cada arquivo `.lpi` encontrado na pasta atual, cria um `version.pas.inc` com metadados do Git e um script de atualização específico por projeto.

**Versão:** 1.0.0  
**Uso:** `git-generator-lcl.sh`  
**Dependências:** `git-lib.sh`, `.gitproject`

---

## O que gera

### `version.pas.inc`

Arquivo de include Pascal com defines de pré-processador prontos para uso no código:

```pascal
{$DEFINE VERSION_STR := '0.3.0'}
{$DEFINE BUILD_DATE := '2026-03-26 22:00:00'}
{$DEFINE GIT_HASH := 'a8b9c0d'}
{$DEFINE GIT_BRANCH := 'main'}
```

### `update-<projeto>.sh`

Script específico por projeto que, quando executado, atualiza simultaneamente o `.lpi` e o `version.pas.inc` com os dados atuais do Git.

---

## Como usar no projeto Lazarus

Inclua o `version.pas.inc` na unit principal e use os defines:

```pascal
{$I version.pas.inc}

procedure TFormMain.FormCreate(Sender: TObject);
begin
  Caption := 'MeuProjeto v' + VERSION_STR;
  StatusBar.SimpleText := 'Build: ' + BUILD_DATE + ' [' + GIT_HASH + ']';
end;
```

Ou em uma tela Sobre:

```pascal
procedure TFormAbout.FormCreate(Sender: TObject);
begin
  LabelVersion.Caption  := 'Versão: ' + VERSION_STR;
  LabelBuild.Caption    := 'Build: '  + BUILD_DATE;
  LabelHash.Caption     := 'Hash: '   + GIT_HASH;
  LabelBranch.Caption   := 'Branch: ' + GIT_BRANCH;
end;
```

---

## Exemplo de execução

```
$ cd /meu/projeto-lazarus
$ git-generator-lcl.sh
✔ MeuProjeto: version.pas.inc e update-MeuProjeto.sh criados/atualizados
🎯 Todos os projetos processados com sucesso!
```

Para projetos com múltiplos `.lpi` na mesma pasta:

```
✔ Modulo1: version.pas.inc e update-Modulo1.sh criados/atualizados
✔ Modulo2: version.pas.inc e update-Modulo2.sh criados/atualizados
🎯 Todos os projetos processados com sucesso!
```

---

## Script gerado: `update-<projeto>.sh`

Cada projeto recebe seu próprio script de atualização. Ele deve ser executado antes de compilar para garantir que o `.lpi` e o `version.pas.inc` reflitam a versão atual:

```bash
update-MeuProjeto.sh
```

**O que ele faz:**

Atualiza os campos de versão dentro do `.lpi`:

```xml
<!-- Antes -->
<MajorVersionNr Value="0"/>
<MinorVersionNr Value="2"/>
<BuildNr Value="1"/>

<!-- Depois -->
<MajorVersionNr Value="0"/>
<MinorVersionNr Value="3"/>
<BuildNr Value="0"/>
```

E regenera o `version.pas.inc` com data e hash atuais do Git.

---

## Fluxo de trabalho recomendado

`git-generator-lcl.sh` é executado **apenas uma vez** por projeto — ele é um gerador. O script que você executa em cada release é o `update-<projeto>.sh` que ele cria.

```
git-generator-lcl.sh        ← roda UMA VEZ para gerar o update-<projeto>.sh
        ↓
update-<projeto>.sh          ← roda em CADA RELEASE
```

**Configuração inicial (uma única vez):**

```bash
# Na raiz do projeto Lazarus
git-generator-lcl.sh
# → gera version.pas.inc e update-MeuProjeto.sh
```

**Dia a dia de desenvolvimento:**

```bash
# 1. Desenvolve e commita normalmente
git-feat.sh "adiciona exportação para PDF"
git-fix.sh "corrige crash ao abrir arquivo vazio"

# 2. Gera o release (bump de versão + tag)
git-release.sh

# 3. Atualiza o .lpi e o version.pas.inc com a nova versão
update-MeuProjeto.sh

# 4. Compila no Lazarus
```

**Quando rodar `git-generator-lcl.sh` novamente:**

- Um novo `.lpi` for adicionado ao projeto
- O `update-<projeto>.sh` for deletado acidentalmente
- Você quiser regenerar o `version.pas.inc` inicial com hash e branch

---

## Diferença em relação ao `git-version-inc.sh`

| Funcionalidade | `git-version-inc.sh` | `git-generator-lcl.sh` |
|----------------|----------------------|------------------------|
| Gera `version.pas.inc` | ✅ | ✅ |
| Hash Git (`GIT_HASH`) | ❌ | ✅ |
| Branch Git (`GIT_BRANCH`) | ❌ | ✅ |
| Atualiza o `.lpi` | ❌ | ✅ |
| Suporte a múltiplos projetos | ❌ | ✅ |
| Gera script por projeto | ❌ | ✅ |

Use `git-version-inc.sh` para projetos simples sem `.lpi`, e `git-generator-lcl.sh` para projetos Lazarus.

---

## Arquivos gerados na pasta do projeto

```
meu-projeto/
├── version.pas.inc                  ← defines para uso no código Pascal
└── update-MeuProjeto.sh         ← script de atualização do .lpi
```

---

## Compatibilidade

| Ambiente | Suporte |
|----------|---------|
| Linux (Bash 4.3+) | ✅ |
| macOS (Bash 5 via Homebrew) | ✅ |
| Git Bash / MSYS2 (Windows) | ✅ |
| WSL | ✅ |