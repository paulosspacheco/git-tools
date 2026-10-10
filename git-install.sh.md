# Script git-install.sh

- **Data da versão:** 2026-10-10
- **Versão:** 4.6.0
- **Objetivo da versão:** acrescentar o passo a passo para iniciantes (abrir o terminal, instalar o Git, senha do `sudo`, ativar os comandos)
- **Observações:** a versão acompanha a do `git-install.sh`; se este texto divergir do código, vale o código

## Visão Geral

Script de instalação automatizada para um conjunto de ferramentas auxiliares do Git, projetado para sistemas Linux. O script instala os scripts do git-tools em `/usr/local/bin`, configura aliases no bash, gera o arquivo de importação para a IDE Lazarus e integra com gerenciadores de arquivos populares (Nemo, Nautilus e Dolphin).

## Passo a Passo para Iniciantes

Se você nunca usou o terminal, siga estes passos na ordem. Eles valem para Debian, Ubuntu, Linux Mint e derivados (que usam o `apt`).

1. **Abra o terminal:** pressione `Ctrl + Alt + T`, ou procure por "Terminal" no menu de aplicativos.

2. **Instale o Git** (pule este passo se `git --version` já mostrar uma versão):

   ```bash
   sudo apt install git
   ```

   O terminal pede a sua senha. **Ao digitar, nada aparece na tela** (nem asteriscos). Isso é normal: digite a senha e pressione `Enter`.

3. **Baixe o projeto** de uma destas formas:

   - Pelo terminal:

     ```bash
     git clone https://github.com/paulosspacheco/git-tools.git
     cd git-tools
     ```

   - Sem usar o Git: baixe o ZIP na página do projeto no GitHub e extraia. Depois, abra a pasta extraída no gerenciador de arquivos, clique com o botão direito num espaço vazio e escolha **Abrir no terminal**.

4. **Execute o instalador** (sem `sudo`):

   ```bash
   bash git-install.sh
   ```

   A senha será pedida uma vez. Se o Git ainda não tiver nome e e-mail configurados, o instalador pergunta.

5. **Ative os comandos** na janela atual do terminal:

   ```bash
   source ~/.bashrc
   ```

   Se preferir, feche o terminal e abra outro.

Pronto. Digite `git-ini` para testar.

## Requisitos

- Sistema operacional Linux
- Bash 4.3 ou superior
- Git instalado (o instalador não verifica nem instala o Git)
- Permissão `sudo` para instalação em `/usr/local/bin`
- Executar a partir da pasta do repositório, que deve conter o `git-tools.conf` e todos os scripts nele listados
- Opcionais: `zenity` e `konsole`. Os scripts de integração do Nemo e do Dolphin tentam instalá-los com `apt` se faltarem

## Funcionalidades

### 1. Instalação de Scripts Git

Os arquivos são copiados com `sudo` para `/usr/local/bin`. Os arquivos `.sh` recebem permissão de execução. Arquivos já existentes são sobrescritos.

**Arquivos extras instalados:**
- `git-lib.sh` - Biblioteca de funções usada pelos demais scripts
- `git-config.sh` - Grava o `.gitproject` do projeto
- `git-hook.sh` - Instala a validação das mensagens de commit
- `git-add-navigator-nemo.sh` - Integração com Nemo
- `git-add-navigator-nautilus.sh` - Integração com Nautilus
- `git-add-navigator-dolphin.sh` - Integração com Dolphin
- `git-tools.conf` - Arquivo de configuração principal

**Scripts adicionais:** todos os definidos no arquivo `git-tools.conf`. Se qualquer arquivo da lista não existir na pasta, a instalação é interrompida com erro.

Scripts que não estão no `git-tools.conf` nem na lista de extras (por exemplo `git-lazarus-integrate.sh`, `git-remove-navigator-nemo.sh` e `mover-para-semuso.sh`) não são copiados e continuam na pasta do repositório.

### 2. Configuração do Git

O script verifica e configura as credenciais globais do Git:

- Verifica se `user.name` e `user.email` estão configurados globalmente
- Se ambos já existem, apenas os exibe
- Se faltar algum, solicita somente o que falta:
  - Sugere o nome com base no campo GECOS do sistema (Enter aceita a sugestão)
  - Valida o formato do e-mail (deve conter `@` e um domínio com ponto)
  - Mostra os dados e pede confirmação `[S/n]` antes de salvar
- Grava as configurações globalmente
- Lê os valores de volta para verificar se foram salvos corretamente
- Em caso de falha ou de resposta `n`, reinicia a configuração

### 3. Aliases no Bash

Adiciona aliases no arquivo `~/.bashrc`. Cada alias tem o nome do script sem `.sh` e leva os parâmetros definidos no `git-tools.conf`. Só recebem alias as linhas do conf que tenham pelo menos um título (de menu ou do Lazarus).

```bash
# Exemplos de aliases criados
alias git-ini='bash "/usr/local/bin/git-ini.sh"'
alias git-feat='bash "/usr/local/bin/git-feat.sh"'
alias git-fix='bash "/usr/local/bin/git-fix.sh"'
alias git-changelog-summary='bash "/usr/local/bin/git-changelog-summary.sh" --html'
```

Os aliases ficam dentro de um bloco demarcado:
```bash
# >>> git-tools start >>>
# <<< git-tools end <<<
```

A cada instalação o bloco anterior é removido e recriado. O restante do `~/.bashrc` não é alterado, mas também não é feito backup do arquivo. Para usar os aliases na sessão atual, execute `source ~/.bashrc`.

### 4. Integração com Lazarus IDE

Gera um arquivo XML (`lazarus.git-tools.xml`) na pasta do repositório, para importação no Lazarus:

- **Formato:** XML compatível com Lazarus
- **Conteúdo:** uma ferramenta para cada linha do `git-tools.conf` que tenha título do Lazarus
- **Configurações incluídas:**
  - Título da ferramenta
  - Caminho do executável em `/usr/local/bin`
  - Parâmetros de linha de comando (quando existirem)
  - Diretório de trabalho (`$ProjPath()`)
  - Scanner FPC configurado

O instalador **não altera** o `environmentoptions.xml` do Lazarus. A importação é manual, e o script mostra as instruções ao final da geração:

1. Abra o Lazarus
2. Acesse `Tools → Configure External Tools...`
3. Clique em `Import` e selecione o arquivo XML gerado
4. Clique em `OK` e reinicie o Lazarus

### 5. Integração com Gerenciadores de Arquivos

Detecta os gerenciadores instalados (com `command -v`) e executa, a partir de `/usr/local/bin`, o script de integração de cada um:

| Gerenciador | Script Correspondente |
|-------------|----------------------|
| Nemo | `git-add-navigator-nemo.sh` |
| Nautilus | `git-add-navigator-nautilus.sh` |
| Dolphin | `git-add-navigator-dolphin.sh` |

**Características:**
- Suporte apenas para Linux; em outros sistemas a etapa é ignorada com um aviso
- Detecta os gerenciadores disponíveis no sistema
- Executa o script específico de cada gerenciador encontrado
- Se um desses scripts terminar com erro, o instalador avisa e continua
- Se nenhum gerenciador for encontrado, apenas avisa
- Os scripts do Nemo e do Dolphin podem executar `sudo apt update` e `sudo apt install` para instalar dependências ausentes

### 6. Medidas de Segurança

O script implementa diversas verificações de segurança:

- **Prevenção de execução incorreta:**
  - Não pode ser executado com `sudo bash script.sh`
  - Não pode ser executado como usuário root
  - A autenticação `sudo` é solicitada uma única vez, no início da cópia, para não expirar no meio da instalação

- **Validações:**
  - Verifica a existência de cada arquivo antes de copiar
  - Valida o formato do e-mail
  - Confirma os dados antes de salvar as configurações do Git
  - Verifica se os dados foram salvos corretamente

- **Tratamento de erros:**
  - `set -euo pipefail` para interromper em erros
  - Mensagens de erro claras (função `die`)
  - Loop de retry para a configuração do Git

### 7. Execução repetida

Executar o instalador novamente é seguro: os arquivos são recopiados, o bloco de aliases é recriado, o XML do Lazarus é gerado de novo, os scripts de integração recriam os menus, e o Git só é configurado se faltar `user.name` ou `user.email`.

## Estrutura do Arquivo de Configuração

O arquivo `git-tools.conf` segue o formato CSV com pipe (`|`) como delimitador:

```
script.sh|Título Menu|Título Lazarus|Parâmetros
```

**Colunas:**
1. `script` - Nome do arquivo do script
2. `title_menu` - Título exibido no menu do gerenciador de arquivos (opcional)
3. `title_laz` - Título para integração com Lazarus (opcional)
4. `params` - Parâmetros passados ao script (opcional)

Linhas iniciadas por `#` e linhas em branco são ignoradas. O formato completo está descrito em `git-tools-conf.md`.

## Como Usar

### Instalação

```bash
# Clone ou baixe os arquivos do projeto
git clone https://github.com/paulosspacheco/git-tools.git
cd git-tools

# Execute o instalador (NÃO use sudo)
bash git-install.sh
```

### Pós-instalação

```bash
# Recarregar os aliases no bash
source ~/.bashrc

# Verificar instalação
ls -la /usr/local/bin/git-*

# Testar um comando
git-ini  # Inicializar repositório
```

### Exemplos de Comandos Disponíveis

Após a instalação, os comandos listados no `git-tools.conf` estarão disponíveis. Exemplos:

```bash
git-ini                    # Preparar o repositório Git
git-feat "funcionalidade"  # Commit de nova funcionalidade
git-fix "correção"         # Commit de correção
git-refactor "refatoração" # Commit de refatoração
git-reset                  # Desfazer o último commit
git-undo-reset             # Recuperar um commit desfeito
git-release                # Calcular a versão e criar a tag
git-github                 # Enviar o projeto ao GitHub
```

Ao final da instalação, o script exibe um exemplo de uso e a lista completa de aliases criados.

## Fluxo de Execução

O script segue esta sequência de operações:

1. **Verificações iniciais:**
   - Não executar como root
   - Não executar com sudo

2. **Instalação dos scripts:**
   - Autenticação sudo
   - Cópia de arquivos extras
   - Cópia de scripts do arquivo de configuração

3. **Geração do XML do Lazarus:**
   - Parse do arquivo de configuração
   - Geração do XML estruturado
   - Exibição das instruções de importação manual

4. **Configuração do Git:**
   - Verificação de configurações existentes
   - Solicitação interativa quando necessário
   - Validação e salvamento

5. **Configuração de aliases:**
   - Limpeza de blocos anteriores
   - Adição de novos aliases no `~/.bashrc`

6. **Integração com gerenciadores:**
   - Detecção de gerenciadores disponíveis
   - Execução dos scripts de integração

7. **Mensagem final:**
   - Exemplo de uso
   - Listagem dos aliases disponíveis

## Mensagens e Feedback

O script fornece feedback usando emojis no terminal:

- `🚀` - Início de operação
- `✔` - Operação bem-sucedida
- `❌` - Erro ou falha
- `⚠` - Aviso ou informação importante
- `🔧` - Configuração em andamento
- `👉` - Instrução para o usuário
- `↩` - Reinício ou repetição

## Tratamento de Erros

### Erros Comuns e Soluções

| Erro | Causa | Solução |
|------|-------|---------|
| `❌ Configuração não encontrada` | Arquivo `git-tools.conf` ausente | Executar a partir da pasta do repositório, onde está o arquivo |
| `❌ Arquivo não encontrado` | Script listado no `git-tools.conf` não existe na pasta | Restaurar o arquivo ou retirar a linha do conf |
| `❌ Falha ao copiar` | Sem permissão de escrita em `/usr/local/bin` | Verificar as permissões do diretório e do `sudo` |
| `❌ Falha na autenticação sudo` | Senha incorreta ou sem permissão | Verificar permissões sudo do usuário |
| `❌ Não execute com sudo` | Script chamado com sudo | Executar sem sudo: `bash git-install.sh` |
| `❌ Não execute como root` | Script executado pelo usuário root | Executar com um usuário comum |
| `⚠ Nenhum gerenciador suportado encontrado` | Nemo, Nautilus e Dolphin não estão instalados | Aviso apenas; os comandos de terminal funcionam normalmente |

## Logs e Debug

O instalador não grava arquivo de log; toda a saída aparece no terminal. Para executar com debug:

```bash
bash -x git-install.sh
```

Para guardar a saída em um arquivo (opcional):

```bash
bash git-install.sh 2>&1 | tee install.log
```

## Desinstalação

Para remover as ferramentas, execute a partir da pasta do repositório:

```bash
bash git-uninstall.sh
source ~/.bashrc
```

O `git-uninstall.sh` remove os scripts de `/usr/local/bin`, o `lazarus.git-tools.xml`, os aliases do `~/.bashrc` (com backup em `~/.bashrc.bak-uninstall`), a configuração de ferramentas externas do Lazarus e os menus dos gerenciadores de arquivos. Os detalhes estão em `git-uninstall.sh.md`.

No Nemo, o item **Git Tools** pode continuar no menu depois da desinstalação, porque o Nemo usa o arquivo `Git Tools.sh`, que o desinstalador não apaga. Para removê-lo:

```bash
rm "$HOME/.local/share/nemo/scripts/Git Tools.sh"
```

## Arquivos envolvidos

- `/usr/local/bin/` - recebe os scripts e o `git-tools.conf`
- `~/.bashrc` - recebe o bloco de aliases
- `lazarus.git-tools.xml` - criado na pasta do repositório
- Arquivos de menu do Nemo, Nautilus e Dolphin, criados pelos scripts de integração
- `~/.gitconfig` - recebe `user.name` e `user.email`, se estavam vazios

## Limitações

- **SO:** Funciona apenas em Linux (a integração com gerenciadores é ignorada em outros sistemas, verificada por `OSTYPE`)
- **Shell:** Requer Bash (não compatível com outros shells)
- **Gerenciadores:** Suporte limitado a Nemo, Nautilus e Dolphin
- **Permissões:** Necessita acesso sudo para instalação global
- **Dependências:** O Git deve estar pré-instalado; o instalador não o verifica
- **Lazarus:** a importação do XML é manual

## Notas de Segurança Importantes

1. **Nunca execute com `sudo bash script.sh`** - O script gerencia a autenticação internamente
2. **Nunca execute como root** - O script verifica e impede a execução como root
3. **Confirme os dados solicitados** - Especialmente e-mail e nome do Git
4. **Verifique os aliases adicionados** - Revise o bloco do git-tools no `~/.bashrc`
5. **Arquivos existentes são sobrescritos** - Em `/usr/local/bin`, sem confirmação

## Suporte

Para problemas ou dúvidas:

1. Execute com debug: `bash -x git-install.sh`
2. Leia as mensagens exibidas no terminal
3. Confirme que todos os arquivos listados no `git-tools.conf` estão presentes na pasta
4. Verifique as permissões do diretório `/usr/local/bin`