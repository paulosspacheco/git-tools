# 'readme.md' do projeto  git-tools

Comandos curtos para guardar cada versão do seu trabalho — documentos, páginas e programas — usando o Git. Cada operação (nova funcionalidade, correção, release, changelog, desfazer) pergunta o necessário, monta a mensagem no padrão [Conventional Commits](https://www.conventionalcommits.org/) e calcula a versão ([SemVer](https://semver.org/)) a partir do que foi feito.

**Versão:** 1.0.2  
**Data:** 2026-10-09

**Objetivo da versão:** corrigir a tabela de scripts: remove os que não existem no projeto, inclui o `mover-para-semuso.sh` e liga cada script ao seu próprio documento. O uso rápido ganha o `git-github`, e o texto de conversa que estava no fim do arquivo foi retirado.

**Observações:** cada script tem o seu documento ao lado do fonte, com o nome do script mais `.md` (`git-lib.sh` → `git-lib.sh.md`). Ao criar um documento novo, acrescente a linha correspondente na tabela de scripts abaixo.

---

## O que você precisa

- Linux com Bash 4.3 ou superior
- Git instalado
- `sudo`, pois os scripts são copiados para `/usr/local/bin`
- Opcionais: `zenity` (janelas gráficas), `pandoc` (gerar o `CHANGELOG.html`) e `konsole` (integração com o Dolphin)
- Para enviar ao GitHub (`git-github`): `ssh`, `curl` e uma chave SSH cadastrada na sua conta

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
git-changelog-summary              # grava o CHANGELOG.md e o CHANGELOG.html (exige pandoc)
git-github                         # envia o projeto ao GitHub
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
| [CHANGELOG.md](CHANGELOG.md) | Histórico de mudanças, agrupado por tipo. O `CHANGELOG.html` é gerado na sua máquina com `--html` e não vai para o repositório |
| [lazarus_git-tools.xml.md](lazarus_git-tools.xml.md) | Ferramentas externas do Lazarus (XML de importação) |
| [LICENSE](LICENSE) | Licença MIT |

### Scripts

Os aliases têm o nome do script sem o `.sh` (`git-feat.sh` → `git-feat`).

| Script | Para que serve | Documento |
|--------|----------------|-----------|
| `git-ini.sh` | Prepara o projeto: repositório, `.gitignore`, `README.md`, hooks e remoto | [git-ini.sh.md](git-ini.sh.md) |
| `git-feat.sh` | Commit de nova funcionalidade (`feat:`) | [git-feat.sh.md](git-feat.sh.md) |
| `git-fix.sh` | Commit de correção (`fix:`) | [git-fix.sh.md](git-fix.sh.md) |
| `git-breaking.sh` | Commit de mudança que quebra compatibilidade (`feat!:`) | [git-breaking.sh.md](git-breaking.sh.md) |
| `git-refactor.sh` | Commit de refatoração (`refactor:`) | [git-refactor.sh.md](git-refactor.sh.md) |
| `git-docs.sh` | Commit de documentação (`docs:`) | [git-docs.sh.md](git-docs.sh.md) |
| `git-version.sh` | Calcula a próxima versão, cria a tag e atualiza os arquivos de versão (`version-pas.inc` em projetos Pascal) | [git-version.sh.md](git-version.sh.md) |
| `git-release.sh` | Executa o `git-version.sh` e mostra a versão gerada | [git-release.sh.md](git-release.sh.md) |
| `git-changelog.sh` | Mostra os commits agrupados por versão | [git-changelog.sh.md](git-changelog.sh.md) |
| `git-changelog-summary.sh` | Gera o `CHANGELOG.md` agrupado por tipo de commit e, com `--html`, o `CHANGELOG.html` (o alias já inclui `--html`) | [git-changelog-summary.sh.md](git-changelog-summary.sh.md) |
| `git-reset.sh` | Desfaz o último commit | [git-reset.sh.md](git-reset.sh.md) |
| `git-undo-reset.sh` | Recupera um commit desfeito | [git-undo-reset.sh.md](git-undo-reset.sh.md) |
| `git-github.sh` | Envia o projeto ao GitHub e cria o repositório se não existir | [git-github.sh.md](git-github.sh.md) |
| `git-install.sh` | Instala scripts, aliases e menus | [git-install.sh.md](git-install.sh.md) |
| `git-uninstall.sh` | Remove tudo o que o instalador criou | [git-uninstall.sh.md](git-uninstall.sh.md) |
| `git-lib.sh` | Biblioteca de funções usada pelos demais scripts | [git-lib.sh.md](git-lib.sh.md) |
| `git-lib-test.sh` | Testa o carregamento da biblioteca `git-lib.sh` e as funções `load_config` e `ask_required` | [git-lib-test.sh.md](git-lib-test.sh.md) |
| `git-config.sh` | Grava o `.gitproject` com nome e versão do projeto | [git-config.sh.md](git-config.sh.md) |
| `git-hook.sh` | Instala a validação das mensagens de commit | [git-hook.sh.md](git-hook.sh.md) |
| `git-add-navigator-nemo.sh`<br>`git-add-navigator-nautilus.sh`<br>`git-add-navigator-dolphin.sh` | Criam o submenu **Git Tools** no gerenciador de arquivos | [nemo](git-add-navigator-nemo.sh.md)<br>[nautilus](git-add-navigator-nautilus.sh.md)<br>[dolphin](git-add-navigator-dolphin.sh.md) |
| `git-remove-navigator-nemo.sh` | Remove o submenu do Nemo | [git-remove-navigator-nemo.sh.md](git-remove-navigator-nemo.sh.md) |
| `git-lazarus-integrate.sh` | Integração avulsa com o menu Tools do Lazarus | [git-lazarus-integrate.sh.md](git-lazarus-integrate.sh.md) |
| `mover-para-semuso.sh` | Move para `semuso/` os arquivos que não fazem parte do projeto (aceita `--simular`) | [guia](git-tools-claude.md#neste-repositório) |

---

## Licença

Distribuído sob a licença MIT. O texto completo está em [LICENSE](LICENSE).