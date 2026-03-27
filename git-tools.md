# git-tools

Conjunto de scripts Bash para gerenciamento de projetos Git com foco em simplicidade. Permite que qualquer pessoa — mesmo sem experiência com Git — siga boas práticas de versionamento automaticamente.

**Versão:** 0.3.0  
**Requisito:** Bash 4.3+ · Git · Debian/Ubuntu (para instalação automática do Git)

---

## O que o projeto entrega

- Obriga o padrão de mensagens de commit (Conventional Commits)
- Impede erros humanos com validações e confirmações
- Calcula a versão semântica automaticamente (SemVer)
- Cria tags Git automaticamente a cada release
- Gera `version.inc` pronto para uso em projetos Lazarus/FPC
- Funciona em qualquer pasta após instalação

---

## Instalação

Clone o repositório e execute o instalador:

```bash
git clone https://github.com/seu-usuario/git-tools.git
cd git-tools
./git-install.sh
```

Os scripts serão copiados para `/usr/local/bin` e estarão disponíveis globalmente.

---

## Scripts

### `git-ini.sh` — Inicialização de projeto

Prepara um repositório Git do zero. Deve ser executado uma única vez por projeto.

**O que faz:**
- Instala o Git se ausente (Debian/Ubuntu)
- Configura nome e e-mail do usuário Git se ainda não configurados
- Inicializa o repositório com branch `main`
- Gera `.gitignore` básico
- Gera `.gitproject` com nome e versão inicial
- Instala o hook de validação de commits
- Cria o commit inicial com `README.md`
- Oferece configuração de repositório remoto

**Uso:**
```bash
cd /meu/projeto
git-ini.sh
```

**Exemplo de execução:**
```
🚀 Inicializando projeto
Seu nome completo: Paulo Pacheco
Seu e-mail: paulo@email.com
✔ .gitignore criado
✔ .gitproject criado
✔ Hook instalado

Arquivos que serão incluídos no commit inicial:
A  .gitignore
A  .gitproject
A  README.md

Confirmar? [S/n]: s
[main a1b2c3d] feat: inicialização do projeto
URL do repositório remoto (Enter para pular):
✔ Projeto pronto
```

---

### `git-feat.sh` — Commit de nova funcionalidade

Usado quando algo **novo** é adicionado ao projeto.

**Uso:**
```bash
git-feat.sh "descrição da funcionalidade"
# ou sem argumento — o script pergunta
git-feat.sh
```

**Exemplo:**
```bash
git-feat.sh "adiciona tela de login"
# → [main c4d5e6f] feat: adiciona tela de login
```

---

### `git-fix.sh` — Commit de correção de bug

Usado quando algo que **já existia** é corrigido.

**Uso:**
```bash
git-fix.sh "descrição da correção"
```

**Exemplo:**
```bash
git-fix.sh "corrige validação de senha em branco"
# → [main d5e6f7a] fix: corrige validação de senha em branco
```

---

### `git-breaking.sh` — Commit de quebra de compatibilidade

Usado quando uma mudança **quebra compatibilidade** com versões anteriores. Incrementa o MAJOR na versão (ex: `1.4.2 → 2.0.0`).

**Uso:**
```bash
git-breaking.sh "descrição da mudança"
```

**Exemplo:**
```bash
git-breaking.sh "remove suporte ao formato de config antigo"
# → [main e6f7a8b] feat!: remove suporte ao formato de config antigo
```

---

### `git-release.sh` — Geração de release

Executa o fluxo completo de release: calcula a nova versão, cria a tag Git e gera o `version.inc`.

**Uso:**
```bash
git-release.sh
```

**Exemplo:**
```
🚀 Gerando release
[main f7a8b9c] chore: bump version para v0.3.0
✔ Versão atualizada: v0.2.1 → v0.3.0
[main a8b9c0d] chore: atualiza version.inc para v0.3.0
✔ version.inc gerado: v0.3.0 — 2026-03-26 22:00:00
✔ Release criado: v0.3.0
```

---

### `git-version.sh` — Cálculo de versão semântica

Analisa os commits desde a última tag e incrementa a versão conforme o tipo:

| Tipo de commit | Efeito |
|----------------|--------|
| `feat!:` | MAJOR+1, MINOR=0, PATCH=0 |
| `feat:` | MINOR+1, PATCH=0 |
| `fix:` | PATCH+1 |

Atualiza `.gitproject` e cria a tag Git automaticamente. Chamado internamente pelo `git-release.sh`.

---

### `git-version-inc.sh` — Geração do version.inc para Lazarus/FPC

Gera o arquivo `version.inc` com defines de pré-processador prontos para uso em projetos Lazarus.

**Arquivo gerado:**
```pascal
{$DEFINE VERSION_STR := '0.3.0'}
{$DEFINE BUILD_DATE := '2026-03-26 22:00:00'}
```

**Como usar no projeto Lazarus:**
```pascal
{$I version.inc}

procedure TFormMain.FormCreate(Sender: TObject);
begin
  Caption := 'Meu Projeto v' + {$IFDEF VERSION_STR} VERSION_STR {$ENDIF};
end;
```

---

### `git-hook.sh` — Instalação do hook de commits

Instala o hook `commit-msg` que rejeita automaticamente mensagens fora do padrão. Chamado internamente pelo `git-ini.sh`. Os hooks ficam em `.githooks/` (versionado) e se propagam para quem clonar o repositório.

**Prefixos aceitos:**

| Prefixo | Quando usar |
|---------|-------------|
| `feat:` | Nova funcionalidade |
| `fix:` | Correção de bug |
| `feat!:` | Quebra de compatibilidade |
| `docs:` | Documentação |
| `chore:` | Tarefas internas (build, versão) |
| `refactor:` | Refatoração sem mudança de comportamento |
| `test:` | Testes |
| `style:` | Formatação, espaços, ponto e vírgula |

**Exemplo de rejeição:**
```
$ git commit -m "arrumei o bug"
❌ Mensagem de commit inválida!
   Use um dos prefixos: feat:, fix:, docs:, chore:, refactor:, test:, style:, feat!:
   Exemplo: feat: adiciona tela de login
```

---

### `git-config.sh` — Configuração do projeto

Gera o arquivo `.gitproject` com os metadados do projeto. Chamado internamente pelo `git-ini.sh`.

**Arquivo gerado:**
```
PROJECT_NAME=meu-projeto
VERSION=0.1.0
```

---

### `git-lib.sh` — Biblioteca utilitária

Base compartilhada pelos demais scripts. Não é executado diretamente.

**Funções disponíveis para outros scripts:**

`ask_required VAR "prompt" [valor]` — garante que um valor obrigatório existe  
`load_config` — carrega variáveis do `.gitproject`

---

### `git-install.sh` — Instalação global

Copia todos os scripts para `/usr/local/bin`, tornando-os disponíveis em qualquer pasta do sistema.

**Uso:**
```bash
cd git-tools
./git-install.sh
```

---

## Fluxo de trabalho típico

### Iniciando um projeto novo
```bash
cd /meu/projeto
git-ini.sh
```

### Dia a dia de desenvolvimento
```bash
# Adicionou algo novo
git-feat.sh "adiciona exportação para PDF"

# Corrigiu um bug
git-fix.sh "corrige crash ao abrir arquivo vazio"

# Mudança que quebra compatibilidade
git-breaking.sh "altera formato do arquivo de configuração"
```

### Gerando um release
```bash
git-release.sh
```

O sistema calcula automaticamente a nova versão com base nos commits feitos desde o último release.

---

## Estrutura de arquivos gerados

```
meu-projeto/
├── .git/               # Repositório Git (gerado automaticamente)
├── .githooks/          # Hooks versionados (propagam ao clonar)
│   └── commit-msg
├── .gitignore          # Arquivos ignorados pelo Git
├── .gitproject         # Metadados do projeto (nome, versão)
├── version.inc         # Defines para Lazarus/FPC
└── README.md           # Documentação inicial
```

---

## Compatibilidade

| Ambiente | Suporte |
|----------|---------|
| Linux (Bash 4.3+) | ✅ |
| macOS (Bash 5 via Homebrew) | ✅ |
| macOS (Bash 3.x padrão) | ❌ nameref não disponível |
| Git Bash / MSYS2 (Windows) | ✅ |
| WSL | ✅ |