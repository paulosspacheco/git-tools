# git-lib.sh

Biblioteca utilitária para scripts Git em Bash. Fornece funções auxiliares para leitura de parâmetros obrigatórios, confirmação interativa e carregamento seguro de configurações por projeto.

**Versão:** 1.1.0  
**Uso:** `source git-lib.sh`  
**Requisito:** Bash 4.3+ (nameref)

---

## Funções

### `ask_required <var> <prompt> [valor]`

Garante que um valor obrigatório existe. Se `valor` não for fornecido (ou estiver vazio), solicita entrada interativa ao usuário. Atribui o resultado à variável indicada por `var`.

**Parâmetros**

| Parâmetro | Descrição |
|-----------|-----------|
| `var` | Nome da variável de saída (nameref) |
| `prompt` | Texto exibido ao solicitar entrada |
| `valor` | Valor pré-existente (opcional) |

**Retorno**

- `0` — valor obtido com sucesso
- `1` — valor continua vazio após interação; mensagem de erro enviada para stderr

**Exemplo**

```bash
source git-lib.sh

ask_required REPO "Informe o repositório" "$REPO"
ask_required BRANCH "Informe a branch"

echo "Repositório: $REPO"
echo "Branch: $BRANCH"
```

---

### `ask_confirm <var> <prompt> [default]`

Solicita uma confirmação interativa ao usuário. Exibe `[S/n]` e atribui a resposta à variável indicada por `var`. Se o usuário pressionar Enter sem digitar nada, usa o valor padrão.

**Parâmetros**

| Parâmetro | Descrição |
|-----------|-----------|
| `var` | Nome da variável de saída (nameref) |
| `prompt` | Texto exibido ao solicitar confirmação |
| `default` | Valor padrão se Enter for pressionado (`s` por padrão) |

**Retorno**

- `0` — sempre; a decisão de continuar ou abortar é do script chamador

**Exemplo**

```bash
source git-lib.sh

ask_confirm CONFIRM "Deseja continuar?" "n"
if [[ "$CONFIRM" =~ ^[Nn]$ ]]; then
  echo "Cancelado."
  exit 0
fi

ask_confirm REMOVE "Remover arquivo?" "s"
if [[ ! "$REMOVE" =~ ^[Nn]$ ]]; then
  rm arquivo.txt
fi
```

---

### `load_config`

Carrega variáveis do arquivo `.gitproject` no diretório atual, se existir. Apenas chaves compostas por letras maiúsculas e `_` (`A-Z_`) são aceitas, prevenindo execução de código arbitrário.

**Formato esperado do `.gitproject`**

```
PROJECT_NAME=meu-projeto
VERSION=0.3.0
```

**Retorno**

- `0` — configurações carregadas (ou arquivo ausente, sem erro)

**Exemplo**

```bash
source git-lib.sh
load_config

echo "Versão atual: $VERSION"
```

---

## Exemplo completo

```bash
#!/bin/bash
source git-lib.sh

load_config

ask_required PROJECT_NAME "Nome do projeto" "$PROJECT_NAME"
ask_required BRANCH       "Branch"          "main"

ask_confirm CONFIRM "Confirmar inicialização?" "s"
if [[ "$CONFIRM" =~ ^[Nn]$ ]]; then
  echo "Cancelado."
  exit 0
fi

echo "→ $PROJECT_NAME @ $BRANCH"
```

---

## Segurança

- `load_config` usa parser manual em vez de `source`, aceitando apenas chaves `A-Z_`; valores não são validados — evite expor o `.gitproject` a entradas não confiáveis
- `ask_required` e `ask_confirm` usam `read -r`, preservando barras invertidas em caminhos Windows (`C:\Users\...`)
- Mensagens de erro vão para stderr, mantendo stdout limpo para captura

---

## Compatibilidade

| Ambiente | Suporte |
|----------|---------|
| Linux (Bash 4.3+) | ✅ |
| macOS (Bash 3.x padrão) | ❌ nameref não disponível |
| macOS (Bash 5 via Homebrew) | ✅ |
| Git Bash / MSYS2 (Windows) | ✅ |
| WSL | ✅ |