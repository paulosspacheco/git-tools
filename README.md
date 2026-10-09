# git-tools

Comandos curtos para guardar cada versão do seu trabalho — documentos, páginas e programas — usando o Git. Cada operação (nova funcionalidade, correção, release, changelog, desfazer) pergunta o necessário, monta a mensagem no padrão [Conventional Commits](https://www.conventionalcommits.org/) e calcula a versão ([SemVer](https://semver.org/)) a partir do que foi feito.

**Versão:** 1.0.0  
**Data:** 2026-10-09

**Objetivo da versão:** README passa a ser a porta de entrada do projeto e o índice de todos os documentos. Os arquivos HTML gerados automaticamente foram removidos; a documentação existe somente em Markdown.

**Observações:** cada script tem o seu documento ao lado do fonte, com o nome do script mais `.md` (`git-lib.sh` → `git-lib.sh.md`). Ao criar um documento novo, acrescente a linha correspondente na tabela de scripts abaixo.

---

## O que você precisa

- Linux com Bash 4.3 ou superior
- Git instalado
- `sudo`, pois os scripts são copiados para `/usr/local/bin`
- Opcionais: `zenity` (janelas gráficas) e `konsole` (integração com o Dolphin)

Sem ambiente gráfico, todos os comandos funcionam com perguntas no terminal.

## Instalação

```bash
git clone https://github.com/paulosspacheco/git-tools.git
cd git-tools
bash git-install.sh
source ~/.bashrc
```

Não execute o instalador como root: ele pede `sudo` sozinho quando precisa. Para remover, use `bash git-uninstall.sh`.

## Uso rápido

```bash
cd /meu/projeto
git-ini                            # prepara o repositório
git-feat "adiciona tela de login"
git-fix "corrige validação de senha"
git-release                        # calcula a versão e cria a tag
git-changelog-summary --write      # salva o CHANGELOG.md
```

Os mesmos comandos aparecem no menu de contexto do Nemo, Nautilus e Dolphin e no menu **Tools** do Lazarus.

---

## Documentação

### Guias

| Documento | Conteúdo |
|-----------|----------|
| [git-tools-claude.md](git-tools-claude.md) | Guia completo: instalação, todos os comandos, integrações e pontos de atenção |
| [git-tools.conf.md](git-tools.conf.md) | Como o `git-tools.conf` define scripts, menus e aliases |
| [resumo.md](resumo.md) | Guia rápido dos comandos do Git |
| [CHANGELOG.md](CHANGELOG.md) | Histórico de mudanças, agrupado por tipo |
| [LICENSE](LICENSE) | Licença MIT |

### Scripts

Os aliases têm o nome do script sem o `.sh` (`git-feat.sh` → `git-feat`).

| Script | Para que serve | Documento |
|--------|----------------|-----------|
| `git-ini.sh` | Prepara o projeto: repositório, `.gitignore`, `README.md`, hooks e remoto | [guia](git-tools-claude.md#git-ini) |
| `git-feat.sh` | Commit de nova funcionalidade (`feat:`) | [guia](git-tools-claude.md#commits) |
| `git-fix.sh` | Commit de correção (`fix:`) | [guia](git-tools-claude.md#commits) |
| `git-breaking.sh` | Commit de mudança que quebra compatibilidade (`feat!:`) | [guia](git-tools-claude.md#commits) |
| `git-refactor.sh` | Commit de refatoração (`refactor:`) | [guia](git-tools-claude.md#commits) |
| `git-docs.sh` | Commit de documentação (`docs:`) | [guia](git-tools-claude.md#commits) |
| `git-version.sh` | Calcula a próxima versão, cria a tag e gera o `version-pas.inc` | [guia](git-tools-claude.md#versão-e-release) |
| `git-release.sh` | Executa o `git-version.sh` e mostra a versão gerada | [guia](git-tools-claude.md#versão-e-release) |
| `git-changelog.sh` | Mostra os commits agrupados por versão | [guia](git-tools-claude.md#changelog) |
| `git-changelog-summary.sh` | Gera o `CHANGELOG.md` agrupado por tipo de commit | [guia](git-tools-claude.md#changelog) |
| `git-reset.sh` | Desfaz o último commit | [guia](git-tools-claude.md#desfazer) |
| `git-undo-reset.sh` | Recupera um commit desfeito | [guia](git-tools-claude.md#desfazer) |
| `git-github.sh` | Envia o projeto ao GitHub e cria o repositório se não existir | [git-github.sh.md](git-github.sh.md) |
| `git-install.sh` | Instala scripts, aliases e menus | [git-install.sh.md](git-install.sh.md) |
| `git-uninstall.sh` | Remove tudo o que o instalador criou | [guia](git-tools-claude.md#desinstalação) |
| `git-lib.sh` | Biblioteca de funções usada pelos demais scripts | [git-lib.sh.md](git-lib.sh.md) |
| `git-config.sh` | Grava o `.gitproject` com nome e versão do projeto | [guia](git-tools-claude.md#git-ini) |
| `git-hook.sh` | Instala a validação das mensagens de commit | [guia](git-tools-claude.md#hook-de-commit) |
| `git-add-navigator-nemo.sh`<br>`git-add-navigator-nautilus.sh`<br>`git-add-navigator-dolphin.sh` | Criam o submenu **Git Tools** no gerenciador de arquivos | [guia](git-tools-claude.md#gerenciadores-de-arquivos) |
| `git-remove-navigator-nemo.sh` | Remove o submenu do Nemo | [guia](git-tools-claude.md#gerenciadores-de-arquivos) |
| `git-lazarus-integrate.sh` | Integração avulsa com o menu Tools do Lazarus | [guia](git-tools-claude.md#lazarus) |
| `git-generator-lcl.sh` | Gera os arquivos de versão dos projetos Lazarus | [git-generator-lcl.sh.md](git-generator-lcl.sh.md) |

---

## Licença

Distribuído sob a licença MIT. O texto completo está em [LICENSE](LICENSE).