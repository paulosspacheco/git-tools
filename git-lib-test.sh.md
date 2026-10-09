# `git-lib-test.sh` — Teste de carregamento da biblioteca `git-lib.sh`

Não há versão nem data informadas no cabeçalho do script.

## Visão geral

O `git-lib-test.sh` é um script de teste que verifica o funcionamento básico da biblioteca `git-lib.sh`. Ele carrega as configurações do `.gitproject`, obtém dois valores (repositório e branch) e exibe o resultado no terminal.

Os valores que já estiverem definidos não são perguntados de novo. Só o que estiver faltando é solicitado ao usuário.

É útil para confirmar que a biblioteca está acessível e que as funções `load_config` e `ask_required` funcionam corretamente.

## Pré-requisitos

- Bash 4.3 ou superior (a biblioteca usa `local -n`).
- `git-lib.sh` no mesmo diretório do script, ou acessível pelo caminho de busca do shell (`PATH`). Com o git-tools instalado, ele está em `/usr/local/bin`.
- `zenity` (opcional): havendo ambiente gráfico e `zenity`, os valores faltantes são pedidos em janelas. Caso contrário, no terminal.
- Opcional: um arquivo `.gitproject` na pasta atual com as chaves `REPO` e `BRANCH`. Se faltar, o script pergunta.

## Como utilizar

Execute o script na pasta onde está (ou onde deseja criar) o `.gitproject`:

```bash
./git-lib-test.sh
```

O script irá:

1. Carregar `git-lib.sh`.
2. Carregar as configurações do `.gitproject` da pasta atual, com `load_config`.
3. Obter o **repositório** (`REPO`): se já estiver definido, usa o valor; senão, pergunta.
4. Obter a **branch** (`BRANCH`): se já estiver definida, usa o valor; senão, pergunta.
5. Exibir o resultado no formato:

```text
→ <repositório> @ <branch>
```

### Exemplo 1 — sem `.gitproject`

Nenhum valor está definido, então o script pergunta os dois. Os exemplos usam um repositório do GitHub no formato `usuário/repositório` (o endereço completo seria `https://github.com/paulosspacheco/git-tools`):

```text
Repositório: paulosspacheco/git-tools
Branch: main
→ paulosspacheco/git-tools @ main
```

### Exemplo 2 — com `.gitproject` completo

Arquivo `.gitproject` na pasta atual:

```text
REPO=paulosspacheco/git-tools
BRANCH=main
```

Nada é perguntado:

```text
→ paulosspacheco/git-tools @ main
```

### Exemplo 3 — com `.gitproject` parcial

Se o arquivo tiver só a linha `REPO=paulosspacheco/git-tools`, o script pergunta apenas a branch:

```text
Branch: dev
→ paulosspacheco/git-tools @ dev
```

Variáveis `REPO` e `BRANCH` já definidas no ambiente do shell (por exemplo, com `export BRANCH=main`) têm o mesmo efeito que o `.gitproject`.

## Como funciona

1. Carrega as funções de `git-lib.sh` com `source`.
2. Executa `load_config` para ler o `.gitproject` da pasta atual. Só são aceitas chaves com letras maiúsculas e `_`.
3. Usa `ask_required` duas vezes, para `REPO` e para `BRANCH`. Se a variável já tem valor, `ask_required` o usa sem perguntar. Se está vazia, pergunta em uma janela (`zenity`) ou no terminal.
4. Imprime a combinação final com `echo`.

## Comportamento e segurança

- **Somente leitura:** o script não altera arquivos nem executa comandos Git.
- **Sem validação:** os valores informados não são validados quanto ao formato nem quanto à existência do repositório no GitHub. O texto digitado é apenas exibido.
- **Valor vazio:** no terminal, uma resposta vazia faz a `ask_required` exibir `❌ Valor obrigatório` e retornar erro. O script não verifica esse retorno e continua.
- **Janela cancelada:** se a janela do `zenity` for cancelada, o valor fica vazio e o script imprime o resultado mesmo assim (`→  @ `).
- **Dependência direta:** se `git-lib.sh` não for encontrado, o script falha na linha `source`.
- **Sem versão declarada:** não há metadados de versão nem data no cabeçalho.

## Arquivos envolvidos

- `git-lib.sh` — biblioteca carregada pelo script.
- `.gitproject` — lido por `load_config`, na pasta atual (opcional).

## Solução de problemas

- **`git-lib.sh: No such file or directory`** — execute o script no mesmo diretório de `git-lib.sh`, instale o git-tools (`bash git-install.sh`) ou ajuste o `source` para o caminho correto.
- **`load_config: command not found`** — a função não existe na biblioteca carregada. Verifique se está usando a versão correta do `git-lib.sh`.
- **`ask_required: command not found`** — mesma causa: a função `ask_required` não está disponível na biblioteca.
- **O script não perguntou nada** — `REPO` e `BRANCH` já estavam definidos, no `.gitproject` ou no ambiente do shell. Para testar as perguntas, renomeie o `.gitproject` e limpe as variáveis do ambiente com `unset REPO BRANCH`.
- **O script pergunta tudo, apesar de existir `.gitproject`** — o `load_config` só lê o `.gitproject` da pasta atual. Execute o script na pasta do projeto e confira se as chaves `REPO` e `BRANCH` estão escritas em maiúsculas, no formato `CHAVE=valor`.
- **`→  @ ` com valores vazios** — a janela foi cancelada ou nenhuma resposta foi digitada. Execute de novo e informe os valores.