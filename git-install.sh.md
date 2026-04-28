# Script git-install.sh

## Visão Geral

Script de instalação automatizada para um conjunto de ferramentas auxiliares do Git, projetado para sistemas Linux. O script instala scripts Git, configura aliases no bash, integra com a IDE Lazarus e com gerenciadores de arquivos populares.

**Versão:** 4.6.0

## Requisitos

- Sistema operacional Linux
- Bash shell
- Git instalado
- Permissão sudo para instalação em `/usr/local/bin`
- Arquivos de configuração necessários (ver seção "Arquivos Necessários")

## Funcionalidades

### 1. Instalação de Scripts Git

Os scripts são instalados em `/usr/local/bin` e tornados executáveis:

**Arquivos extras instalados:**
- `git-lib.sh` - Biblioteca de funções Git
- `git-config.sh` - Configuração do Git
- `git-hook.sh` - Gerenciamento de hooks
- `git-add-navigator-nemo.sh` - Integração com Nemo
- `git-add-navigator-nautilus.sh` - Integração com Nautilus
- `git-add-navigator-dolphin.sh` - Integração com Dolphin
- `git-tools.conf` - Arquivo de configuração principal

**Scripts adicionais:** Definidos no arquivo `git-tools.conf`

### 2. Configuração do Git

O script verifica e configura automaticamente as credenciais do Git:

- Verifica se `user.name` e `user.email` estão configurados globalmente
- Se não estiverem configurados, solicita interativamente ao usuário:
  - Valida formato do email (deve conter `@` e domínio válido)
  - Sugere nome baseado no campo GECOS do sistema
  - Confirma os dados antes de salvar
- Grava as configurações globalmente
- Verifica se os valores foram salvos corretamente

### 3. Aliases no Bash

Adiciona aliases no arquivo `~/.bashrc` para facilitar o uso dos comandos:

```bash
# Exemplos de aliases criados
alias git-ini='bash "/usr/local/bin/git-ini.sh"'
alias git-feat='bash "/usr/local/bin/git-feat.sh"'
alias git-fix='bash "/usr/local/bin/git-fix.sh"'
```

Os aliases são adicionados dentro de um bloco demarcado:
```bash
# >>> git-tools start >>>
# <<< git-tools end <<<
```

### 4. Integração com Lazarus IDE

Gera um arquivo XML (`lazarus.git-tools.xml`) para importação no Lazarus:

- **Formato:** XML compatível com Lazarus
- **Conteúdo:** Lista de ferramentas configuradas
- **Configurações incluídas:**
  - Título da ferramenta
  - Caminho do executável
  - Parâmetros de linha de comando
  - Diretório de trabalho (`$ProjPath()`)
  - Scanner FPC configurado

**Como integrar manualmente:**
1. Abra o Lazarus
2. Acesse `Tools → Configure External Tools...`
3. Clique em `Import` e selecione o arquivo XML gerado
4. Clique em `OK` e reinicie o Lazarus

### 5. Integração com Gerenciadores de Arquivos

Detecta e configura automaticamente gerenciadores de arquivos suportados:

| Gerenciador | Script Correspondente |
|-------------|----------------------|
| Nemo | `git-add-navigator-nemo.sh` |
| Nautilus | `git-add-navigator-nautilus.sh` |
| Dolphin | `git-add-navigator-dolphin.sh` |

**Características:**
- Suporte apenas para Linux
- Detecta gerenciadores disponíveis no sistema
- Executa scripts específicos para cada gerenciador
- Fornece feedback visual do processo

### 6. Medidas de Segurança

O script implementa diversas verificações de segurança:

- **Prevenção de execução incorreta:**
  - Não pode ser executado com `sudo bash script.sh`
  - Não pode ser executado como usuário root
  - Autenticação sudo solicitada apenas internamente quando necessário

- **Validações:**
  - Verifica existência de arquivos antes de copiar
  - Valida formato de email
  - Confirma dados antes de salvar configurações
  - Verifica se os dados foram salvos corretamente

- **Tratamento de erros:**
  - `set -euo pipefail` para interromper em erros
  - Mensagens de erro claras (`die` function)
  - Loop de retry para configurações críticas

## Estrutura do Arquivo de Configuração

O arquivo `git-tools.conf` segue o formato CSV com pipe (`|`) como delimitador:

```
script.sh|Título Menu|Título Lazarus|Parâmetros
```

**Colunas:**
1. `script` - Nome do arquivo do script
2. `title_menu` - Título exibido no menu (opcional)
3. `title_laz` - Título para integração com Lazarus (opcional)
4. `params` - Parâmetros passados ao script (opcional)

## Como Usar

### Instalação

```bash
# Clone ou baixe os arquivos do projeto
cd /caminho/para/os/scripts

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

Após a instalação, os seguintes comandos estarão disponíveis (exemplos típicos):

```bash
git-ini                    # Inicializar repositório Git
git-feat "funcionalidade"  # Criar commit de feature
git-fix "correção"         # Criar commit de correção
git-refactor "refatoração" # Criar commit de refatoração
git-reset                  # Resetar alterações
git-undo-reset             # Desfazer reset
git-release                # Criar release
```

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
   - Listagem de comandos disponíveis
   - Instruções de uso

## Mensagens e Feedback

O script fornece feedback visual usando emojis e cores:

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
| `❌ Configuração não encontrada` | Arquivo `git-tools.conf` ausente | Verificar se o arquivo está no mesmo diretório |
| `❌ Arquivo não encontrado` | Script referenciado não existe | Verificar a lista de arquivos necessários |
| `❌ Falha na autenticação sudo` | Senha incorreta ou sem permissão | Verificar permissões sudo do usuário |
| `❌ Não execute com sudo` | Script chamado com sudo | Executar sem sudo: `bash git-install.sh` |

## Logs e Debug

Para executar com debug:

```bash
bash -x git-install.sh
```

## Desinstalação

Para remover as ferramentas:

```bash
# Remover scripts
sudo rm -f /usr/local/bin/git-*.sh
sudo rm -f /usr/local/bin/git-lib.sh
sudo rm -f /usr/local/bin/git-config.sh

# Remover aliases do ~/.bashrc (editar manualmente ou usar sed)
sed -i '/# >>> git-tools start >>>/,/# <<< git-tools end <<</d' ~/.bashrc

# Recarregar configuração
source ~/.bashrc
```

## Limitações

- **SO:** Funciona apenas em Linux (verificado por `OSTYPE`)
- **Shell:** Requer Bash (não compatível com outros shells)
- **Gerenciadores:** Suporte limitado a Nemo, Nautilus e Dolphin
- **Permissões:** Necessita acesso sudo para instalação global
- **Dependências:** Git deve estar pré-instalado

## Notas de Segurança Importantes

1. **Nunca execute com `sudo bash script.sh`** - O script gerencia a autenticação internamente
2. **Nunca execute como root** - O script verifica e impede execução como root
3. **Confirme os dados solicitados** - Especialmente email e nome do Git
4. **Verifique os aliases adicionados** - Antes de usar, revise o `~/.bashrc`

## Suporte

Para problemas ou dúvidas:

1. Execute com debug: `bash -x git-install.sh`
2. Verifique os logs de erro
3. Confirme que todos os arquivos necessários estão presentes
4. Verifique as permissões do diretório `/usr/local/bin`
