# Git Tools - Guia do Projeto

## 1. Visão Geral do Projeto

**Git Tools** é um conjunto de scripts Bash para gerenciamento simplificado de projetos Git, projetado para facilitar o uso de boas práticas de versionamento mesmo para usuários sem experiência prévia com Git.

### Tecnologias Principais
- **Bash 4.3+** - Linguagem principal dos scripts
- **Git** - Sistema de controle de versão
- **Zenity** (opcional) - Para interfaces gráficas em ambientes com display
- **Lazarus/FPC** - Suporte a projetos Pascal através do arquivo `version-pas-inc`

### Arquitetura em Alto Nível
O projeto segue uma arquitetura modular onde:
- `git-lib.sh` fornece funções utilitárias compartilhadas
- Scripts específicos (`git-feat.sh`, `git-fix.sh`, etc.) implementam funcionalidades específicas
- Hooks Git garantem a conformidade com Conventional Commits
- Configurações são centralizadas no arquivo `.gitproject`

## 2. Primeiros Passos

### Pré-requisitos
- Bash 4.3 ou superior
- Git instalado
- Ambiente Linux/Unix (Debian/Ubuntu, macOS com Bash 5+, Git Bash no Windows)
- Zenity (opcional, para interfaces gráficas)

### Instalação
```bash
# Clone o repositório
git clone https://github.com/seu-usuario/git-tools.git
cd git-tools

# Instale globalmente
./git-install.sh
```

### Exemplos Básicos de Uso
```bash
# Inicializar um novo projeto
cd /meu/projeto
git-ini.sh

# Adicionar uma nova funcionalidade
git-feat.sh "adiciona tela de login"

# Corrigir um bug
git-fix.sh "corrige validação de senha"

# Gerar um release
git-release.sh
```

### Como Executar Testes
O projeto inclui `git-lib-test.sh` para testar a biblioteca utilitária:
```bash
./git-lib-test.sh
```

## 3. Estrutura do Projeto

```
git-tools/
├── .continue/rules/           # Este guia e regras do Continue
├── .git/                      # Repositório Git
├── .githooks/                 # Hooks versionados
│   └── commit-msg            # Validação de mensagens de commit
├── .gitignore                # Padrões de arquivos ignorados
├── .gitproject               # Configurações do projeto (nome, versão)
├── README.md                 # Documentação principal
├── git-tools.md              # Documentação detalhada
├── git-lib.sh                # Biblioteca utilitária (core)
├── git-ini.sh                # Inicialização de projetos
├── git-feat.sh               # Commits de funcionalidades
├── git-fix.sh                # Commits de correções
├── git-breaking.sh           # Commits com quebra de compatibilidade
├── git-release.sh            # Geração de releases
├── git-version.sh            # Cálculo de versão semântica
├── git-hook.sh               # Instalação de hooks
├── git-config.sh             # Configuração do projeto
├── git-install.sh            # Instalação global
├── git-uninstall.sh          # Desinstalação
├── version-pas-inc.sh        # Geração de arquivo para Lazarus/FPC
├── git-*.sh                  # Outros scripts utilitários
└── version-pas-inc           # Arquivo gerado para projetos Pascal
```

### Arquivos-Chave e Seus Papéis

1. **git-lib.sh** - Biblioteca central com funções utilitárias:
   - `ask_required()` - Solicita valores obrigatórios
   - `ask_confirm()` - Confirmações interativas
   - `notify_info()` - Exibição de mensagens
   - `load_config()` - Carregamento de configurações

2. **.gitproject** - Configurações do projeto:
   ```bash
   PROJECT_NAME=git-tools
   VERSION=0.14.1
   ```

3. **git-hook.sh** - Implementa validação de Conventional Commits

### Arquivos de Configuração Importantes
- **.gitignore** - Padrões específicos para projetos Lazarus/FPC
- **.gitproject** - Metadados do projeto
- **lazarus.git-tools.xml** - Configuração para integração com Lazarus IDE

## 4. Fluxo de Desenvolvimento

### Padrões ou Convenções de Cabeçalho de Scripts
Cada script segue um formato padrão:
```bash
#!/bin/bash
# =============================================================================
# nome-do-script.sh — Descrição breve
# =============================================================================
# Descrição detalhada
#
# Uso: ./nome-do-script.sh [parâmetros]
#
# Versão: x.y.z
# Dependências: script1.sh, script2.sh
# =============================================================================
```

### Estratégia de Testes
- Testes manuais dos scripts em diferentes cenários
- Verificação de compatibilidade com diferentes ambientes
- Testes de integração entre scripts

### Processo de Build e Deploy
1. **Desenvolvimento**: Modificar scripts conforme necessário
2. **Testes**: Verificar funcionamento em diferentes ambientes
3. **Versionamento**: Usar os próprios scripts para commits
4. **Release**: `git-release.sh` para gerar nova versão
5. **Distribuição**: `git-install.sh` para instalação global

### Diretrizes para Contribuição
1. Use os scripts do projeto para commits:
   - `git-feat.sh` para novas funcionalidades
   - `git-fix.sh` para correções
   - `git-breaking.sh` para mudanças que quebram compatibilidade

2. Mantenha a compatibilidade com Bash 4.3+

3. Documente novas funcionalidades em `git-tools.md`

4. Teste em diferentes ambientes (Linux, macOS, Git Bash)

## 5. Conceitos-Chave

### Terminologia Específica
- **Conventional Commits**: Padrão de mensagens de commit (feat:, fix:, etc.)
- **SemVer**: Versionamento Semântico (MAJOR.MINOR.PATCH)
- **Hook Git**: Script executado automaticamente em eventos Git
- **version-pas-inc**: Arquivo com defines para projetos Pascal

### Abstrações Principais
1. **Configuração por Projeto**: Cada projeto tem seu `.gitproject`
2. **Hooks Versionados**: Hooks são armazenados em `.githooks/`
3. **Interface Adaptativa**: Scripts usam Zenity (GUI) ou terminal (CLI)

### Padrões de Design Utilizados
1. **Biblioteca Compartilhada**: `git-lib.sh` centraliza funcionalidades comuns
2. **Scripts Específicos**: Cada funcionalidade tem seu script dedicado
3. **Fallback Graceful**: GUI → CLI quando Zenity não disponível
4. **Configuração Externa**: Parâmetros via argumentos ou interativamente

## 6. Tarefas Comuns

### Adicionar um Novo Script
1. Crie o arquivo com extensão `.sh`
2. Adicione o cabeçalho padrão
3. Importe `git-lib.sh` se necessário
4. Documente no `git-tools.md`
5. Teste o funcionamento

### Modificar a Biblioteca Utilitária
1. Edite `git-lib.sh`
2. Atualize a versão no cabeçalho
3. Teste com `git-lib-test.sh`
4. Verifique compatibilidade com scripts existentes

### Atualizar a Documentação
1. Modifique `git-tools.md` para mudanças funcionais
2. Atualize `README.md` para visão geral
3. Revise exemplos e casos de uso

### Adicionar Suporte a Nova Plataforma
1. Teste os scripts na nova plataforma
2. Identifique incompatibilidades
3. Modifique condicionais (`_has_display()`, etc.)
4. Documente na seção de compatibilidade

## 7. Solução de Problemas

### Problemas Comuns

#### "❌ Nenhum repositório Git encontrado"
**Causa**: Script executado fora de um repositório Git
**Solução**: Execute `git-ini.sh` primeiro ou navegue para um projeto Git

#### "❌ Mensagem de commit inválida!"
**Causa**: Mensagem não segue Conventional Commits
**Solução**: Use um dos prefixos aceitos: `feat:`, `fix:`, `feat!:`, `docs:`, `chore:`, `refactor:`, `test:`, `style:`

#### Scripts não encontrados após instalação
**Causa**: `/usr/local/bin` não está no PATH
**Solução**: Adicione ao PATH ou use caminho completo:
```bash
export PATH="/usr/local/bin:$PATH"
```

#### Zenity não disponível em ambiente headless
**Causa**: Ambiente sem display (servidores, SSH)
**Solução**: Os scripts automaticamente usam interface de terminal

### Dicas de Depuração
1. **Modo verboso**: Adicione `set -x` no início do script para debug
2. **Teste individual**: Execute cada função separadamente
3. **Verifique dependências**: Use `command -v` para verificar comandos
4. **Log de execução**: Redirecione saída para arquivo:
   ```bash
   ./git-feat.sh 2>&1 | tee debug.log
   ```

### Compatibilidade entre Versões de Bash
- **Bash 4.3+**: Suporte completo
- **Bash 3.x (macOS padrão)**: Problemas com `local -n` (nameref)
- **Solução**: Instalar Bash 5 via Homebrew no macOS

## 8. Referências

### Documentação do Projeto
- [git-tools.md](./git-tools.md) - Documentação completa
- [README.md](./README.md) - Visão geral
- [CHANGELOG.md](./CHANGELOG.md) - Histórico de mudanças

### Padrões e Especificações
- [Conventional Commits](https://www.conventionalcommits.org/) - Padrão de mensagens
- [Semantic Versioning](https://semver.org/) - Versionamento semântico
- [Bash Reference Manual](https://www.gnu.org/software/bash/manual/) - Documentação Bash

### Ferramentas Relacionadas
- [Git Documentation](https://git-scm.com/doc) - Documentação oficial do Git
- [Zenity](https://wiki.gnome.org/Projects/Zenity) - Ferramenta para diálogos GTK
- [Lazarus IDE](https://www.lazarus-ide.org/) - Ambiente de desenvolvimento Pascal

### Recursos Importantes
- **Scripts de integração**: `git-lazarus-integrate.sh` para Lazarus
- **Navegadores de arquivos**: Scripts para Dolphin, Nautilus, Nemo
- **Workspace**: `git-tools.code-workspace` para VS Code

---
*Este guia foi gerado automaticamente com base na análise do projeto. Revise e edite conforme necessário para refletir mudanças futuras.*

**Próximos passos:**
1. Revise este arquivo e ajuste conforme necessário
2. Faça commit no repositório: `git-feat.sh "adiciona guia CONTINUE.md"`
3. Compartilhe com a equipe para padronização
4. O Continue carregará automaticamente este contexto ao trabalhar no projeto

Para documentações específicas de componentes, crie arquivos `rules.md` em subdiretórios relevantes.