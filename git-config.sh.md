# `git-config.sh` — Configuração básica do projeto Git

**Versão:** 1.0.0

## Visão geral

O `git-config.sh` gera o arquivo `.gitproject`, que armazena metadados básicos do projeto: o nome e uma versão inicial. Esse arquivo pode ser usado por outros scripts da suíte para identificar o projeto.

## Pré-requisitos

- Bash.
- `git-lib.sh` no mesmo diretório do script, com a função `ask_required`.

## Como utilizar

```bash
./git-config.sh [nome-do-projeto]
```

- **Com argumento:** o nome informado é usado diretamente.
- **Sem argumento:** o script solicita o nome do projeto.

O nome não pode conter barras (`/`), nem começar com `/`. Deve ser um nome simples, como `meu-projeto`.

### Exemplo

```bash
./git-config.sh meu-projeto
```

Resultado — arquivo `.gitproject` criado com:

```text
PROJECT_NAME=meu-projeto
VERSION=0.1.0
```

## Como funciona

1. Carrega as funções auxiliares de `git-lib.sh`, localizado no mesmo diretório do script.
2. Obtém o nome do projeto: se há argumento, usa-o sem perguntar; sem argumento, solicita (em janela ou no terminal).
3. Valida o nome, rejeitando caminhos com barras.
4. Cria (ou sobrescreve) o arquivo `.gitproject` com o nome e a versão `0.1.0`.
5. Informa que o arquivo foi criado.

## Comportamento e segurança

- **Sobrescrita:** o arquivo `.gitproject` é sempre recriado. Se já existir, seu conteúdo anterior é perdido sem confirmação.
- **Versão fixa:** a versão gravada é sempre `0.1.0`, independentemente do estado do projeto.
- **Nome vazio:** se a resposta for vazia (ou a janela for cancelada), a função exibe `❌ Valor obrigatório`, mas o script continua e grava `PROJECT_NAME=` sem valor.
- **Chamado pelo `git-ini`:** o `git-ini.sh` executa este script uma única vez por repositório, controlado pelo marcador `.git/git-tools-configured`. Se o marcador não existir, o `.gitproject` é recriado e a versão volta a `0.1.0`.
- **Validação parcial:** a checagem rejeita nomes que comecem com `/` ou contenham `/` em qualquer posição. Outros caracteres não são validados.
- **Escrita direta:** o arquivo é gravado sem verificação de permissões ou de erros de escrita.

## Arquivos envolvidos

- `.gitproject` — criado ou sobrescrito no diretório atual.
- `git-lib.sh` — biblioteca de funções, exigida no mesmo diretório.

## Solução de problemas

- **`❌ Nome do projeto não deve ser um caminho`** — use apenas um nome simples, sem barras.
- **Erro ao carregar `git-lib.sh`** — verifique se o arquivo está no mesmo diretório do `git-config.sh`.
- **Conteúdo anterior do `.gitproject` perdido** — o script não preserva versões antigas. Faça backup manualmente antes de executar, se necessário.