# `git-lib.sh` — Biblioteca de funções do git-tools

**Versão:** 1.4.0

## Visão geral

O `git-lib.sh` não é executado diretamente. Ele é carregado pelos demais scripts do git-tools com `source` e oferece funções para perguntar, confirmar, avisar, escolher opções e ler as configurações do projeto.

Quando há ambiente gráfico e o `zenity` está instalado, as funções abrem janelas. Caso contrário, usam o terminal.

## Pré-requisitos

- Bash 4.3 ou superior (as funções usam `local -n`).
- `zenity` (opcional): sem ele, tudo funciona pelo terminal.
- Para `parse_config`: o arquivo `/usr/local/bin/git-tools.conf`, criado pelo `git-install.sh`.

## Como utilizar

No início do script:

```bash
source "/usr/local/bin/git-lib.sh"
```

Exemplo:

```bash
source "/usr/local/bin/git-lib.sh"

load_config
ask_required NOME "Nome do projeto" "$PROJECT_NAME"
ask_confirm OK "Criar o projeto $NOME?"
[ "$OK" = "s" ] || exit 0
notify_info "✔ Projeto $NOME criado"
```

## Funções

Nas funções `ask_*`, o primeiro argumento é o **nome** da variável que receberá a resposta, sem `$`.

| Função | Para que serve |
|--------|----------------|
| `ask_required VAR "pergunta" [valor]` | Obtém um valor que não pode ficar vazio |
| `ask_optional VAR "pergunta" [valor]` | Obtém um valor que pode ficar vazio |
| `ask_confirm VAR "pergunta" [padrão]` | Pergunta sim ou não |
| `ask_select VAR "título" opção...` | Escolhe uma opção de uma lista |
| `notify_info "mensagem"` | Mostra uma mensagem |
| `view_file arquivo` | Exibe um arquivo de texto |
| `load_config` | Lê o `.gitproject` da pasta atual |
| `parse_config filtro função [arquivo]` | Percorre o `git-tools.conf` |

### `ask_required` e `ask_optional`

- Se o terceiro argumento (`valor`) já vier preenchido, ele é usado **sem perguntar**. Ele não é uma sugestão, é um valor já conhecido.
- Se estiver vazio, abre uma janela de entrada (`zenity`) ou lê do terminal.
- `ask_required` exibe `❌ Valor obrigatório` e retorna `1` se o valor continuar vazio.
- `ask_optional` aceita valor vazio.
- Ambas retornam `1` se a janela for cancelada.

```bash
ask_required NOME "Nome do projeto" ""      # sempre pergunta
ask_required NOME "Nome do projeto" "app"   # não pergunta, NOME=app
```

### `ask_confirm`

- Com janela, mostra os botões **Sim** e **Não** e grava `s` ou `n` na variável.
- No terminal, mostra `[S/n]` e grava o que for digitado. Se só pressionar Enter, grava o `padrão` (por omissão, `s`).
- Retorna sempre `0`. Quem chama decide o que fazer com a resposta.

Para confirmar com segurança, compare com `s`:

```bash
ask_confirm CONFIRMA "Apagar a tag?" "n"
[ "$CONFIRMA" = "s" ] || exit 0
```

Testar apenas `n` (`[[ "$CONFIRMA" =~ ^[Nn]$ ]]`) faz qualquer outra resposta, como "nao", ser tratada como "sim".

### `ask_select`

Mostra as opções em uma lista (janela) ou em um menu numerado (terminal) e grava a opção escolhida em `VAR`. Retorna `1` se a janela for cancelada.

```bash
ask_select ACAO "Tipo de correção:" corrige ajusta resolve
```

### `notify_info` e `view_file`

- `notify_info` mostra a mensagem em uma janela ou, sem ambiente gráfico, com `echo -e` (aceita `\n`).
- `view_file` mostra o arquivo em uma janela de texto ou, sem ambiente gráfico, com `less`.

### `load_config`

Lê o arquivo `.gitproject` da **pasta atual** e cria uma variável para cada linha `CHAVE=valor`:

```text
PROJECT_NAME=meu-projeto
VERSION=0.3.0
```

- Só são aceitas chaves com letras maiúsculas e `_`. Outras linhas são ignoradas.
- Se o arquivo não existir, nada acontece e o retorno é `0`.

### `parse_config`

Lê o `git-tools.conf` (formato `SCRIPT|TITULO_MENU|TITULO_LAZARUS|PARAMS`) e chama a função informada para cada linha, passando os quatro campos.

| Filtro | Linhas processadas |
|--------|--------------------|
| `menu` | As que têm `TITULO_MENU` |
| `lazarus` | As que têm `TITULO_LAZARUS` |
| `all` | Todas |

Linhas vazias e comentários (`#`) são ignorados. Se o arquivo não existir, exibe `❌ Config não encontrado` e retorna `1`. O terceiro argumento permite indicar outro arquivo.

```bash
mostrar() { echo "$1 -> $2"; }
parse_config "menu" mostrar
```

## Comportamento e segurança

- **Detecção de tela:** se `DISPLAY` e `WAYLAND_DISPLAY` não existirem (caso comum quando o script é chamado pelo gerenciador de arquivos), a biblioteca tenta recuperá-las e só usa o terminal se não conseguir.
- **Valores do `.gitproject`:** as chaves são filtradas, mas os valores não são validados. Não use um `.gitproject` de origem desconhecida.
- **Nome da variável de saída:** não use `_out`, `prompt`, `value`, `default`, `title` ou `options`, pois são nomes usados dentro das funções e a resposta não chegará à sua variável.
- **Erros:** as mensagens de erro vão para `stderr`.

## Arquivos envolvidos

- `/usr/local/bin/git-lib.sh` — cópia instalada, carregada pela maioria dos scripts.
- `git-ini.sh`, `git-config.sh` e `git-release.sh` carregam a biblioteca da pasta onde o próprio script está.
- `.gitproject` — lido por `load_config`, na pasta atual.
- `/usr/local/bin/git-tools.conf` — lido por `parse_config`.