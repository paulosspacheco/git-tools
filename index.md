# git-tools - Script para facilitar o uso do git console.

## 📌 Scripts para uso diário (recomendados para alias)

Estes são os comandos que você executaria frequentemente no terminal para gerenciar commits, versões, changelog, etc. Eles já estão no seu `git-install.sh` e devem continuar nos aliases:

| Alias | Script | Finalidade |
|-------|--------|-------------|
| `git-feat` | `git-feat.sh` | Adicionar uma nova funcionalidade (commit semântico) |
| `git-fix` | `git-fix.sh` | Corrigir um bug |
| `git-breaking` | `git-breaking.sh` | Marcar uma mudança que quebra compatibilidade |
| `git-refactor` | `git-refactor.sh` | Refatoração de código |
| `git-docs` | `git-docs.sh` | Documentação |
| `git-release` | `git-release.sh` | Criar uma tag de release |
| `git-version` | `git-version.sh` | Mostrar/gerenciar versão do projeto |
| `git-version-pas-inc` | `git-version-pas-inc.sh` | Incrementar versão em arquivos Pascal |
| `git-changelog` | `git-changelog.sh` | Gerar changelog (markdown) |
| `git-ini` | `git-ini.sh` | Inicializar repositório com estrutura padrão |
| `git-config` | `git-config.sh` | Configurar ferramentas (ex: escopo) |
| `git-hook` | `git-hook.sh` | Instalar hooks do Git (ex: pré-commit) |
| `git-reset` | `git-reset.sh` | Desfazer commits (modo seguro) |
| `git-undo-reset` | `git-undo-reset.sh` | Reverter um `git-reset` |

> ✅ Esses 14 aliases já estão no seu `ALIAS_MAP` (versão 3.3.0).

## 🚫 Scripts que **não** devem ter alias (uso interno/único)

| Script | Motivo |
|--------|--------|
| `git-lib.sh` | Biblioteca de funções compartilhadas – nunca chamado diretamente |
| `git-lib-test.sh` | Teste da biblioteca – só para desenvolvimento |
| `git-generator-lcl.sh` | Gera arquivos `.lpi` / `.lpr` – usado internamente pelo `git-ini.sh` ou `git-release.sh` |
| `git-lazarus-integrate.sh` | Integração com Lazarus (executado uma vez, não diário) |
| `git-add-navigator-*.sh` | Adiciona atalhos no Dolphin/Nautilus/Nemo – instalação única |
| `git-remove-navigator-nemo.sh` | Remove atalhos – desinstalação |
| `git-changelog_ordem_data.sh` | Versão alternativa do changelog (por data) – se quiser, pode criar um alias separado, mas não essencial |
| `git-uninstall.sh` | Desinstalador – não faz parte do uso diário |

## 🤔 Scripts opcionais (você decide se cria alias)

- **`git-changelog_ordem_data.sh`** – Se você usa frequentemente changelog ordenado por data (não por tipo), pode criar um alias como `git-changelog-data`.
- **`git-add-navigator-*`** – São instaladores de integração com o gerenciador de arquivos. Depois de instalados, você não precisa do alias; pode executar diretamente do menu de contexto. Mas se quiser um atalho para reinstalar, crie um alias como `git-navigator-install`.

## 📝 Resumo para o seu `git-install.sh`

Mantenha os aliases exatamente como estão na versão 3.3.0 (os 14 listados acima). Os demais scripts (navigator, generator, lib, test, uninstall) **não devem ser copiados para `/usr/local/bin`** – eles podem ficar apenas no diretório do projeto, pois são executados esporadicamente ou usados como módulos.

Verifique se a lista `SCRIPTS` no instalador contém **apenas os scripts que merecem estar no PATH global**. Sugiro remover da lista `SCRIPTS` os seguintes (caso estejam presentes):

- `git-lib.sh` (não é executável diretamente)
- `git-generator-lcl.sh` (é usado internamente por outros, mas pode ficar – não faz mal)
- `git-lib-test.sh` (não instalar)
- `git-add-navigator-*` (opcional: se quiser que fiquem disponíveis globalmente, pode manter, mas alias não é necessário)

Atualmente seu `SCRIPTS` não inclui esses navegadores, então está correto.

## ✅ Conclusão

- **Alias essenciais (14)** – os que você já tem.
- **Scripts gerais (instalados em /usr/local/bin)** – os mesmos da lista `SCRIPTS` (exceto `git-lib.sh` se não quiser poluir o PATH).
- **Scripts de suporte** – deixe apenas no diretório do projeto, sem alias, sem cópia global.

Se quiser, posso fornecer uma versão final do `git-install.sh` com a lista `SCRIPTS` ajustada e os aliases já padronizados.