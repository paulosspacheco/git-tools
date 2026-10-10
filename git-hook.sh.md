# `git-hook.sh` — Instalação de hooks Git do projeto

**Versão:** 1.1.0  
**Data:** 2026-10-09

**Objetivo da versão:** gravar o hook em `.githooks/commit-msg` e definir o `core.hooksPath`, para que a validação de fato execute. Antes o hook ficava em `.git/hooks`, que o Git ignora quando `core.hooksPath` aponta para `.githooks`.

**Observações:** executar na raiz do repositório. A pasta `.githooks` é versionada, mas quem clonar o projeto precisa rodar este script (ou `git config core.hooksPath .githooks`) uma vez.

---

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

Não são aceitos parâmetros. O script atua sobre o repositório do diretório atual. O `git-ini.sh` já o executa na inicialização do projeto.

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
2. Cria a pasta `.githooks`, se ainda não existir.
3. Grava nela o arquivo `commit-msg` com um script que valida o prefixo da mensagem de commit.
4. Torna o hook executável com `chmod +x`.
5. Define `core.hooksPath` como `.githooks` no repositório.
6. Informa que o hook foi instalado.

A partir daí o Git executa o hook a cada tentativa de commit.

## Comportamento e segurança

- O arquivo `.githooks/commit-msg` é **sobrescrito** se já existir. Não há verificação prévia nem confirmação.
- O script **substitui** um `core.hooksPath` que o repositório já tenha. Se o projeto usa outra pasta de hooks, os hooks dela deixam de executar.
- A pasta `.githooks` entra no repositório (os comandos de commit usam `git add .`), mas o Git não ativa o `core.hooksPath` em quem clona. Quem clonar o projeto deve rodar `git config core.hooksPath .githooks` uma vez.
- O hook valida apenas o prefixo da mensagem. O restante do texto não é verificado.
- O prefixo deve estar no início da mensagem, sem espaços antes. A validação considera a mensagem completa, incluindo linhas de comentário geradas pelo Git.
- Mensagens automáticas do Git, como `Merge branch ...` e `Revert ...`, não começam por um prefixo e são bloqueadas.

## Arquivos envolvidos

- `.githooks/commit-msg` — hook criado ou sobrescrito pelo script.
- `.git/config` — recebe `core.hooksPath = .githooks`.

## Solução de problemas

- **`❌ Nenhum repositório Git encontrado`** — execute o script dentro de um repositório Git já inicializado (por exemplo, após rodar `git-ini.sh` ou `git init`).
- **Commit bloqueado mesmo com prefixo correto** — verifique se o prefixo está exatamente no início da mensagem, seguido de `:`. Espaços ou caracteres antes do prefixo invalidam a mensagem.
- **Hook não está sendo executado** — confirme com `git config core.hooksPath` (deve mostrar `.githooks`) e com `ls -l .githooks/commit-msg` (deve ter permissão de execução). Se algum dos dois falhar, rode `git-hook.sh` de novo.
- **Projeto criado antes da versão 1.1.0** — o hook ficava em `.git/hooks` e não executava. Rode `git-ini` na pasta: ele detecta que falta `.githooks/commit-msg` e instala o hook.