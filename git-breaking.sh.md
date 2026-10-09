# `git-breaking.sh` — Commit de mudança incompatível

**Versão:** 1.1.0

## Visão geral

O `git-breaking.sh` cria um commit de mudança incompatível (*breaking change*) seguindo o padrão Conventional Commits, com o prefixo `feat!:`. Use este script quando a alteração quebra compatibilidade com versões anteriores do projeto.

O script conduz o usuário por etapas: escolha do tipo de mudança, descrição e confirmação antes de efetivar o commit.

## Pré-requisitos

- Bash.
- `git-lib.sh` disponível em `/usr/local/bin/git-lib.sh`, com as funções `ask_select`, `ask_required`, `ask_confirm` e `notify_info`.
- Um repositório Git já inicializado no diretório atual (deve existir a pasta `.git`).

## Como utilizar

```bash
git-breaking.sh ["mensagem"]
```

- **Sem argumento:** o script solicita a descrição da mudança de forma interativa.
- **Com argumento:** a mensagem informada é usada diretamente, sem solicitar descrição.

O script deve ser executado na raiz do repositório.

### Exemplo interativo

```bash
./git-breaking.sh
```

O script pergunta:

1. **Tipo de breaking change:** `remove`, `altera`, `renomeia` ou `reestrutura`.
2. **Descrição da quebra de compatibilidade.**
3. **Confirmação** do commit (responder `s` para confirmar).

### Exemplo com mensagem direta

```bash
./git-breaking.sh "remove parâmetro obsoleto da API de autenticação"
```

Nesse caso, apenas a escolha do tipo e a confirmação são solicitadas.

## Como funciona

1. Carrega as funções auxiliares de `git-lib.sh`.
2. Verifica se o diretório `.git` existe. Se não existir, encerra com código `1`.
3. Solicita o tipo de mudança (`remove`, `altera`, `renomeia` ou `reestrutura`).
4. Obtém a mensagem: usa o primeiro argumento, se informado; caso contrário, solicita a descrição.
5. Monta a mensagem no formato `feat!: <tipo> : <mensagem>`.
6. Exibe a mensagem final com um aviso de breaking change e pede confirmação.
7. Se confirmado, executa `git add .` e `git commit -m`.
8. Informa o resultado.

## Comportamento e segurança

- **Adição ampla:** o script executa `git add .`, incluindo todos os arquivos modificados e não rastreados do diretório atual. Arquivos não desejados podem entrar no commit.
- **Confirmação obrigatória:** o commit só é criado se o usuário responder `s`. Qualquer outra resposta cancela a operação e o script encerra com código `0`.
- **Aviso explícito:** a pergunta de confirmação destaca que se trata de uma breaking change.
- **Sem verificação de mudanças:** o script não verifica se há alterações antes de executar `git add .` ou `git commit`. Se não houver nada para commitar, o Git apresentará sua própria mensagem.
- **Formato da mensagem:** a mensagem gerada segue o padrão `feat!: <tipo> : <descrição>`, com espaços ao redor dos dois-pontos.
- **Cancelamento:** não há commit nem alteração no repositório quando o usuário não confirma.

## Arquivos envolvidos

- `.git/` — repositório onde o commit é criado.
- `git-lib.sh` — biblioteca externa de funções, exigida em `/usr/local/bin/`.

## Solução de problemas

- **`❌ Nenhum repositório Git encontrado`** — execute o script dentro de um repositório Git inicializado.
- **Erro ao carregar `git-lib.sh`** — verifique se o arquivo existe em `/usr/local/bin/git-lib.sh` e se está acessível.
- **Commit não criado** — confirme se a resposta à pergunta de confirmação foi exatamente `s`.
- **Arquivos indesejados incluídos no commit** — o script usa `git add .`; revise o `git status` antes de confirmar e, se necessário, ajuste o `.gitignore`.