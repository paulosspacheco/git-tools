# `git-hook.sh` — Instalação de hooks Git do projeto

**Versão:** 1.0.0

## Visão geral

O `git-hook.sh` instala um hook `commit-msg` no repositório Git local. Esse hook valida automaticamente o formato das mensagens de commit, exigindo que comecem com um dos prefixos do padrão [Conventional Commits](https://www.conventionalcommits.org/):

`fix:`, `feat:`, `feat!:`, `docs:`, `chore:`, `refactor:`, `test:` ou `style:`

O objetivo é manter um histórico de commits padronizado e legível.

## Pré-requisitos

- Bash.
- Um repositório Git já inicializado no diretório atual (deve existir a pasta `.git`).

## Como utilizar

Execute o script na raiz do repositório:

```bash
./git-hook.sh
```

Não são aceitos parâmetros. O script atua sobre o repositório do diretório atual.

### Exemplos de mensagens válidas

```text
feat: adiciona tela de login
fix: corrige cálculo de total
docs: atualiza instruções de instalação
feat!: altera assinatura da API pública
```

### Exemplo de mensagem inválida

```text
adiciona tela de login
```

Ao tentar commitar com uma mensagem inválida, o Git exibirá a orientação do hook e o commit será bloqueado.

## Como funciona

1. Verifica se o diretório `.git` existe. Se não existir, exibe uma mensagem de erro e encerra com código `1`.
2. Cria o arquivo `.git/hooks/commit-msg` com um script que valida o prefixo da mensagem de commit.
3. Torna o hook executável com `chmod +x`.
4. Informa que o hook foi instalado.

O hook passa a ser executado automaticamente pelo Git a cada tentativa de commit, desde que `core.hooksPath` não esteja definido (veja *Comportamento e segurança*).

## Comportamento e segurança

- O arquivo `.git/hooks/commit-msg` é **sobrescrito** se já existir. Não há verificação prévia nem confirmação.
- O hook é instalado apenas no repositório local (`.git/hooks/`), não sendo versionado nem compartilhado automaticamente com outros clones.
- **Projetos criados pelo `git-ini`:** o `git-ini.sh` executa este script e, em seguida, define `core.hooksPath` como `.githooks`. Nenhum script cria essa pasta e, com `core.hooksPath` definido, o Git ignora `.git/hooks`: o hook **não é executado**. Para ativá-lo: `mkdir -p .githooks && cp .git/hooks/commit-msg .githooks/`.
- O hook valida apenas o prefixo da mensagem. O restante do texto não é verificado.
- O prefixo deve estar no início da mensagem, sem espaços antes. A validação considera a mensagem completa, incluindo linhas de comentário geradas pelo Git.

## Arquivos envolvidos

- `.git/hooks/commit-msg` — hook criado ou sobrescrito pelo script.

## Solução de problemas

- **`❌ Nenhum repositório Git encontrado`** — execute o script dentro de um repositório Git já inicializado (por exemplo, após rodar `git-ini.sh` ou `git init`).
- **Commit bloqueado mesmo com prefixo correto** — verifique se o prefixo está exatamente no início da mensagem, seguido de `:`. Espaços ou caracteres antes do prefixo invalidam a mensagem.
- **Hook não está sendo executado** — confirme que o arquivo `.git/hooks/commit-msg` existe e tem permissão de execução. Em projetos criados pelo `git-ini`, confira também `git config core.hooksPath`: se retornar `.githooks`, copie o hook para essa pasta, como descrito em *Comportamento e segurança*.