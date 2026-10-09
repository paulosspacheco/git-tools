# `git-ini.sh` — Inicialização de Repositório Git

**Versão:** 1.4.1  
**Linguagem:** Bash  
**Finalidade:** Inicializar e configurar um repositório Git local de maneira idempotente.

## Sumário

- [`git-ini.sh` — Inicialização de Repositório Git](#git-inish--inicialização-de-repositório-git)
  - [Sumário](#sumário)
  - [1. Objetivo](#1-objetivo)
  - [2. Sintaxe de execução](#2-sintaxe-de-execução)
    - [Parâmetro](#parâmetro)
    - [Exemplos](#exemplos)
  - [3. Dependências](#3-dependências)
    - [Programas e recursos externos](#programas-e-recursos-externos)
    - [Funções fornecidas por `git-lib.sh`](#funções-fornecidas-por-git-libsh)
  - [4. Comportamento idempotente](#4-comportamento-idempotente)
  - [5. Fluxo de execução](#5-fluxo-de-execução)
  - [6. Descrição das etapas](#6-descrição-das-etapas)
    - [6.1. Verificação do Git](#61-verificação-do-git)
    - [6.2. Identidade do usuário](#62-identidade-do-usuário)
    - [6.3. Inicialização do repositório](#63-inicialização-do-repositório)
    - [6.4. Definição do nome do projeto](#64-definição-do-nome-do-projeto)
    - [6.5. Criação do `.gitignore`](#65-criação-do-gitignore)
    - [6.6. Criação do `README.md`](#66-criação-do-readmemd)
    - [6.7. Configurações adicionais](#67-configurações-adicionais)
    - [6.8. Instalação dos hooks](#68-instalação-dos-hooks)
    - [6.9. Criação do commit inicial](#69-criação-do-commit-inicial)
    - [6.10. Configuração do remoto e envio](#610-configuração-do-remoto-e-envio)
  - [7. Arquivos utilizados](#7-arquivos-utilizados)
  - [8. Interação com o usuário](#8-interação-com-o-usuário)
  - [9. Códigos de saída](#9-códigos-de-saída)
  - [10. Considerações técnicas](#10-considerações-técnicas)
    - [10.1. Execuções repetidas](#101-execuções-repetidas)
    - [10.2. Configurações globais](#102-configurações-globais)
    - [10.3. Validação do nome do projeto](#103-validação-do-nome-do-projeto)
    - [10.4. Robustez diante de falhas](#104-robustez-diante-de-falhas)

---

## 1. Objetivo

O script `git-ini.sh` automatiza a preparação inicial de um projeto para utilização do Git.

Suas responsabilidades são:

1. Verificar se o Git está instalado.
2. Configurar globalmente o nome e o e-mail do usuário, caso não estejam definidos.
3. Inicializar um repositório local na branch `main`, caso ainda não exista.
4. Definir o nome do projeto.
5. Criar um `.gitignore` e um `README.md` somente quando esses arquivos não existirem.
6. Executar scripts auxiliares de configuração e instalação de hooks.
7. Preparar e solicitar confirmação para o commit inicial, quando aplicável.
8. Configurar o repositório remoto `origin` e tentar enviar a branch `main`.
9. Informar o resultado das operações.

O script foi projetado para permitir execuções repetidas sem recriar indiscriminadamente os arquivos básicos ou os commits iniciais.

## 2. Sintaxe de execução

```bash
./git-ini.sh [nome-do-projeto]
```

### Parâmetro

| Parâmetro | Obrigatório | Descrição |
|---|---|---|
| `nome-do-projeto` | Não | Nome utilizado na identificação do projeto e na mensagem do commit inicial. |

Quando o nome não é informado, o script usa o nome da pasta atual, **sem perguntar**.

### Exemplos

Inicialização com nome explícito:

```bash
./git-ini.sh miMedia
```

Inicialização com solicitação interativa do nome:

```bash
./git-ini.sh
```

O script deve ser executado no diretório que se deseja transformar em repositório Git. Os arquivos criados e os comandos Git são relativos ao diretório de trabalho atual (`$PWD`), e não necessariamente ao diretório onde o script está armazenado.

## 3. Dependências

### Programas e recursos externos

- **Bash:** interpretador do script.
- **Git:** controle de versão.
- **`git-lib.sh`:** biblioteca de funções auxiliares.
- **`git-config.sh`:** script opcional para configurações adicionais.
- **`git-hook.sh`:** script opcional para instalação dos hooks.

### Funções fornecidas por `git-lib.sh`

O código utiliza as seguintes funções, cuja implementação deve existir na biblioteca:

| Função | Responsabilidade esperada |
|---|---|
| `notify_info` | Exibir mensagens informativas ao usuário. |
| `ask_required` | Solicitar um valor obrigatório. |
| `ask_optional` | Solicitar um valor opcional. |
| `ask_confirm` | Solicitar confirmação do usuário. |

As variáveis preenchidas por essas funções incluem `GIT_USER_NAME`, `GIT_USER_EMAIL`, `PROJECT_NAME`, `REMOTE_URL` e `CONFIRM`.

**Observação:** o comportamento exato dessas funções depende da implementação de `git-lib.sh`.

## 4. Comportamento idempotente

Uma operação é idempotente quando sua repetição não provoca alterações adicionais desnecessárias depois que o estado desejado já foi alcançado.

O script aplica essa estratégia em diferentes etapas:

| Recurso | Comportamento |
|---|---|
| Identidade global do Git | Define nome e e-mail somente se estiverem vazios. |
| Repositório local | Executa `git init` somente se não encontrar o diretório `.git`. |
| `.gitignore` | Cria somente se o arquivo não existir. |
| `README.md` | Cria somente se o arquivo não existir. |
| Configuração adicional | Usa um marcador em `.git/` para evitar nova execução. Sem o marcador, o `git-config.sh` recria o `.gitproject` e a versão volta a `0.1.0`. |
| Hooks | Verifica `core.hooksPath` antes de executar o instalador. |
| Commit inicial | Não cria outro commit inicial quando `HEAD` já existe. |
| Remoto `origin` | Adiciona se não existir; caso exista, atualiza sua URL. |

A idempotência é parcial: o script evita várias operações repetidas, mas não garante que todas as execuções sejam livres de efeitos colaterais. Por exemplo, uma URL remota pode ser atualizada e um `git push` pode ser tentado novamente.

## 5. Fluxo de execução

```text
Início
  |
  v
Carrega git-lib.sh
  |
  v
Verifica instalação do Git
  |
  v
Configura nome e e-mail globais, se necessário
  |
  v
Inicializa o repositório, se necessário
  |
  v
Obtém e valida o nome do projeto
  |
  v
Cria .gitignore e README.md, se ausentes
  |
  v
Executa git-config.sh, se necessário
  |
  v
Executa git-hook.sh, se necessário
  |
  v
Já existe um commit?
  |                 |
 Não                Sim
  |                 |
  v                 |
Adiciona arquivos   |
  |                 |
Existem alterações? |
  |                 |
  v                 |
Solicita confirmação|
  |                 |
Cria commit inicial |
  |                 |
  +--------+--------+
           |
           v
Solicita URL remota opcional
           |
           v
Configura origin e tenta push
           |
           v
Exibe mensagem final
```

O diagrama representa o fluxo principal. Falhas em determinadas operações podem encerrar o script antes da conclusão.

## 6. Descrição das etapas

### 6.1. Verificação do Git

O script verifica a disponibilidade do executável:

```bash
if ! command -v git >/dev/null 2>&1; then
    notify_info "❌ Git não encontrado.\nInstale o Git e tente novamente."
    exit 1
fi
```

O redirecionamento de saída e de erros evita que a verificação exiba mensagens técnicas desnecessárias.

Se o Git não estiver disponível no `PATH`, o script apresenta uma mensagem e termina com código de saída `1`.

### 6.2. Identidade do usuário

O script consulta a configuração global:

```bash
git config --global user.name
git config --global user.email
```

Se algum valor estiver vazio, solicita a informação e a grava na configuração global do Git.

A configuração global afeta os repositórios do usuário que utilizam esse arquivo de configuração. Portanto, o nome e o e-mail definidos não ficam restritos ao projeto atual.

A identidade configurada será utilizada pelo Git na autoria dos commits, salvo quando houver configurações de prioridade superior, como as específicas do repositório.

### 6.3. Inicialização do repositório

O script verifica a existência do diretório `.git`:

```bash
if [ ! -d ".git" ]; then
    git config --global init.defaultBranch main
    git init
else
    echo "ℹ Repositório já existe, reutilizando..."
fi
```

Quando o diretório não existe:

1. Define `main` como branch padrão global para futuras inicializações.
2. Executa `git init`.
3. Informa que o repositório foi inicializado.

Quando `.git` já existe, reutiliza o repositório encontrado.

**Importante:** a verificação de `.git` pressupõe um repositório comum. Ela não contempla explicitamente todos os casos possíveis, como um arquivo `.git` utilizado por worktrees ou um diretório de trabalho localizado dentro de um repositório Git já existente.

Além disso, o script não verifica o código de saída de `git init` nem de `git config` nessa etapa.

### 6.4. Definição do nome do projeto

O nome padrão é obtido por:

```bash
DEFAULT_NAME=$(basename "$PWD")
```

Se o primeiro argumento tiver sido informado, ele será utilizado. Caso contrário, o script usa o nome da pasta atual **sem perguntar**: o valor é passado à `ask_required` já preenchido, e essa função só abre a pergunta quando o valor está vazio.

Em seguida, rejeita nomes que contenham barras:

```bash
if [[ "$PROJECT_NAME" == */* ]] ||
   [[ "$PROJECT_NAME" == *\\* ]]; then
    notify_info "❌ Nome do projeto não deve conter barras. Use apenas um nome simples."
    exit 1
fi
```

Essa validação impede barras normais (`/`) e barras invertidas (`\`).

Embora a mensagem solicite apenas letras, números, hífens ou underscores, a implementação não aplica uma expressão regular que limite o nome a esses caracteres. Ela rejeita apenas os dois tipos de barra indicados.

O nome também é utilizado no título inicial do `README.md` e na mensagem do commit inicial.

### 6.5. Criação do `.gitignore`

Se o arquivo não existir, o script cria um arquivo contendo regras para ignorar:

- Objetos e binários compilados.
- Arquivos temporários e logs.
- Arquivos gerados pelo Lazarus e pelo Free Pascal Compiler (FPC).
- Arquivos de configuração potencialmente sensíveis, como `.env`, `*.key` e `*.pem`.

Exemplo do conteúdo gerado:

```gitignore
# Binários e compilados
*.o
*.a
*.so
*.exe
*.out

# Lazarus / FPC
*.compiled
*.bak
*.lps
*.ppu
*.or
lib/

# Temporários
*.tmp
*.log
*~

# Segredos
.env
*.key
*.pem
```

O uso de `<<'EOF'` impede que o shell expanda variáveis ou execute substituições no conteúdo do heredoc.

Se o `.gitignore` já existir, ele será mantido sem alterações.

**Limitação:** as regras não removem do controle de versão arquivos que já tenham sido adicionados ou commitados anteriormente. Também não garantem, por si só, que todos os segredos e arquivos gerados pelo projeto sejam ignorados.

### 6.6. Criação do `README.md`

Quando não existe um `README.md`, o script cria um arquivo contendo somente o título do projeto:

```markdown
# nome-do-projeto
```

O nome utilizado é o valor de `PROJECT_NAME`.

Se o arquivo já existir, ele será preservado. Isso evita a sobrescrita de documentação produzida anteriormente.

### 6.7. Configurações adicionais

O script localiza os auxiliares a partir do diretório onde está armazenado:

```bash
SCRIPT_DIR="$(dirname "$0")"
```

Se `git-config.sh` existir, verifica se o marcador `.git/git-tools-configured` está ausente.

Quando o marcador não existe:

1. Executa `git-config.sh`, passando o nome do projeto como argumento.
2. Encerra o script com código de falha se o auxiliar retornar um status diferente de zero.
3. Cria o marcador após a execução bem-sucedida.

O comando utilizado é:

```bash
bash "$SCRIPT_DIR/git-config.sh" "$PROJECT_NAME"
```

O `git-config.sh` grava o arquivo `.gitproject` com `PROJECT_NAME` e `VERSION=0.1.0`, sobrescrevendo um `.gitproject` que já exista. O marcador registra que o auxiliar foi executado com sucesso anteriormente. Ele não verifica se as configurações feitas pelo auxiliar continuam presentes ou corretas.

Se o auxiliar não existir, o script apresenta um aviso e prossegue.

### 6.8. Instalação dos hooks

O script verifica a configuração local do Git:

```bash
git config core.hooksPath
```

Se o valor não for `.githooks` e o arquivo `git-hook.sh` existir, executa o instalador:

```bash
bash "$SCRIPT_DIR/git-hook.sh"
```

Depois da execução bem-sucedida, define:

```bash
git config core.hooksPath .githooks
```

Se `core.hooksPath` já estiver definido como `.githooks`, a instalação será ignorada.

Caso `git-hook.sh` não exista, o script apresenta um aviso.

**Observação:** a simples configuração de `core.hooksPath` não garante que todos os hooks necessários estejam presentes, sejam executáveis ou funcionem corretamente. Isso depende do conteúdo de `.githooks` e da implementação do instalador.

**No git-tools, o hook fica inativo:** o `git-hook.sh` grava o hook em `.git/hooks/commit-msg`, e nenhum script cria a pasta `.githooks`. Como `core.hooksPath` passa a apontar para `.githooks`, o Git ignora `.git/hooks`, e mensagens de commit sem prefixo são aceitas. Para ativar a validação: `mkdir -p .githooks && cp .git/hooks/commit-msg .githooks/`.

### 6.9. Criação do commit inicial

A criação do commit inicial é condicionada à ausência de um `HEAD` válido:

```bash
if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
```

Se o repositório ainda não possui commits, o script adiciona os arquivos:

```bash
git add .
```

Em seguida, verifica se existem alterações preparadas para commit:

```bash
git diff --cached --quiet
```

Se não houver alterações, informa que não existe nada para commitar.

Caso existam arquivos preparados, apresenta o status e solicita confirmação ao usuário.

Quando a confirmação for `s`, executa:

```bash
git commit -m "feat: inicialização do projeto $PROJECT_NAME"
git branch -M main
```

A mensagem segue uma convenção semelhante ao Conventional Commits, usando o tipo `feat`.

Se o usuário cancelar, o script informa o cancelamento e termina com código `0`.

Se já existir um commit, o script não tenta criar outro commit inicial.

**Pontos de atenção:**

- `git add .` prepara arquivos rastreáveis e não rastreados presentes no escopo da operação, respeitando as regras de exclusão aplicáveis.
- O script não verifica o resultado de `git add` antes de prosseguir.
- O código não verifica explicitamente o resultado de `git commit` antes de executar `git branch -M main`.
- Se o repositório já tiver commits, mas estiver usando outra branch principal, essa etapa não renomeia a branch existente.

### 6.10. Configuração do remoto e envio

O script solicita uma URL remota opcional:

```bash
ask_optional REMOTE_URL "URL do repositório remoto (deixe em branco para pular)"
```

Se a URL não estiver vazia, verifica se existe um remoto chamado `origin`. Exemplo de URL de um repositório do GitHub, por SSH: `git@github.com:paulosspacheco/git-tools.git`. O repositório precisa já existir no GitHub; para criá-lo, use o `git-github`.

Quando `origin` já existe, atualiza sua URL:

```bash
git remote set-url origin "$REMOTE_URL"
```

Quando não existe, adiciona o remoto:

```bash
git remote add origin "$REMOTE_URL"
```

Depois, tenta enviar a branch `main` e configurar o rastreamento remoto:

```bash
git push -u origin main
```

Se o envio for bem-sucedido, informa o sucesso. Caso contrário, apresenta um aviso para verificar a URL e as credenciais.

A saída de erro do `git push` é descartada com `2>/dev/null`, de modo que a causa técnica da falha não é exibida diretamente.

**Condições para o envio funcionar:**

- A URL deve identificar um repositório remoto acessível.
- As credenciais e permissões devem estar corretas.
- A branch local `main` deve existir.
- O servidor remoto deve aceitar a operação de envio.

A execução do `push` não é obrigatória: deixar a URL em branco permite finalizar sem configurar um remoto.

## 7. Arquivos utilizados

| Arquivo ou diretório | Finalidade |
|---|---|
| `git-ini.sh` | Script principal de inicialização. |
| `git-lib.sh` | Biblioteca de funções de interação com o usuário. |
| `git-config.sh` | Configurações adicionais do projeto. |
| `git-hook.sh` | Instalação dos hooks Git. |
| `.git/` | Metadados e configurações internas do repositório. |
| `.git/git-tools-configured` | Marcador de execução bem-sucedida de `git-config.sh`. |
| `.git/hooks/commit-msg` | Hook criado pelo `git-hook.sh`. |
| `.githooks/` | Diretório para onde `core.hooksPath` passa a apontar. Nenhum script o cria. |
| `.gitproject` | Criado pelo `git-config.sh`, com `PROJECT_NAME` e `VERSION=0.1.0`. |
| `.gitignore` | Regras de exclusão de arquivos do controle de versão. |
| `README.md` | Documentação inicial do projeto. |

Os três scripts auxiliares devem ser disponibilizados conforme a organização do projeto. Os dois auxiliares opcionais podem estar ausentes, situação que o script trata com avisos.

## 8. Interação com o usuário

O script pode solicitar as seguintes informações:

| Informação | Quando é solicitada |
|---|---|
| Nome do usuário Git | Quando `user.name` global está vazio. |
| E-mail do usuário Git | Quando `user.email` global está vazio. |
| Nome do projeto | Não é solicitado: sem argumento, usa o nome da pasta atual. |
| Confirmação do commit inicial | Quando existem arquivos preparados e ainda não há commits. |
| URL do repositório remoto | Em todas as execuções que alcançam essa etapa. |

O usuário pode optar por não configurar o remoto deixando a URL em branco.

As mensagens informativas são apresentadas ao longo da execução, incluindo avisos sobre arquivos já existentes, auxiliares ausentes, cancelamento do commit e falhas no envio.

## 9. Códigos de saída

O script utiliza explicitamente os seguintes códigos:

| Código | Significado |
|---|---|
| `0` | Término normal ou cancelamento voluntário do commit inicial. |
| `1` | Git ausente, nome de projeto rejeitado ou falha em um dos scripts auxiliares. |

Outras falhas não são necessariamente convertidas em código `1` pelo script principal. O comportamento final pode depender do último comando executado e da implementação de `git-lib.sh`.

Em particular, a falha no `git push` é tratada como aviso, não como encerramento fatal.

## 10. Considerações técnicas

### 10.1. Execuções repetidas

O script é adequado para reutilizar um diretório de projeto já inicializado, preservando o `.gitignore` e o `README.md` existentes e evitando a criação de um novo commit inicial quando já há commits.

Entretanto, a idempotência depende do estado real do repositório e dos auxiliares. Em particular, o `.gitproject` é recriado (com `VERSION=0.1.0`) quando o marcador `.git/git-tools-configured` não existe. O marcador de configuração, por exemplo, representa que uma execução anterior foi concluída, mas não funciona como verificação contínua de integridade.

### 10.2. Configurações globais

Os comandos a seguir alteram a configuração global do usuário:

```bash
git config --global user.name "$GIT_USER_NAME"
git config --global user.email "$GIT_USER_EMAIL"
git config --global init.defaultBranch main
```

Assim, a execução pode afetar outros projetos Git do mesmo usuário. A opção `init.defaultBranch` define o padrão para novas inicializações, mas não renomeia automaticamente branches de repositórios já existentes.

### 10.3. Validação do nome do projeto

A mensagem solicita letras, números, hífens e underscores, mas a validação implementada impede somente barras normais e invertidas.

Se a intenção for impor estritamente o conjunto de caracteres descrito, será necessário acrescentar uma validação específica, por exemplo, com uma expressão regular.

### 10.4. Robustez diante de falhas

Para tornar o script mais robusto, recomenda-se avaliar:

- A validação do diretório de execução antes de modificar o repositório.
- A verificação do código de saída de cada comando crítico do Git.
- A confirmação de que `git commit` foi concluído antes de renomear a branch.
- A validação do estado da branch `main` antes do envio.
- A exibição de mensagens de erro úteis quando `git push` falhar.
- A validação dos caracteres permitidos no nome do projeto.
- O tratamento de repositórios com `.git` em formato de arquivo, como ocorre em algumas worktrees.
- A possibilidade de o usuário já possuir um `core.hooksPath` personalizado que não deseja substituir.

Esses itens são recomendações de melhoria, não funcionalidades garantidas pela implementação atual.

---

**Resumo:** `git-ini.sh` centraliza a inicialização de um projeto Git, a criação de arquivos básicos, a execução de configurações auxiliares e a tentativa de publicação em um remoto. Sua principal característica é evitar recriações e operações iniciais desnecessárias, preservando arquivos existentes e respeitando a confirmação do usuário para o primeiro commit.