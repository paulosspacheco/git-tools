# 📘 CHANGELOG

## 📦 Histórico completo

### ➕ Funcionalidades

- 2026-03-29 21:30 melhora : git-generator-lcl.sh — feitos os ajustes para que o Lazarus tenha as opções git-reset.sh, git-undo-reset.sh, git-docs.sh e git-refactor.sh
- 2026-03-29 21:12 adiciona : git-add-navigator-nemo.sh - Adicionadas as opções git-reset.sh, git-undo-reset.sh, git-docs.sh e git-refactor.sh.
- 2026-03-29 21:03 adiciona : git-install.sh - Instala dependências antes de fazer a cópia dos scripts para /bin/local/bin.
- 2026-03-29 20:43 adiciona : gigit-breaking.sh - Adicionada a opção de leitura das mensagens usando zenity.
- 2026-03-29 20:39 adiciona : git-feat.sh - Adicionado opção de leitura de documento gráfico usando o zenity
- 2026-03-29 17:41 Adiciona função ask_select em git-lib.sh
- 2026-03-29 12:20 Ajuste do script git-lib para que detecte quando o script foi executado do gerenciador de arquivos.
- 2026-03-29 12:11 Foi apagao o arquivo. t.txt pois o mesmo não faz nada.
- 2026-03-29 11:21 Adicionados os scripts git-reset.sh e git-undo-reset.sh ao projeto git-tools.
- 2026-03-28 17:10 Adicionado o script git-add-navigator-doelphin.sh para adicionar o submenu no gerenciador de arquivos do KDE Dolphin.
- 2026-03-28 15:54 Adicionado o script git-add-navigator-nautilus.sh para adicionar o submenu no gerenciador de arquivos Nautilus.
- 2026-03-28 14:47 Adiciona ao script git-changelog.sh uma coluna com o número da versão do projeto.
- 2026-03-28 12:04 Adicionado o script git-add-navigator.sh para adicionar o submenu no gerenciador de arquivos Nemo.
- 2026-03-28 11:22 Adicionada a integração automática do projeto git-tools com a LCL.
- 2026-03-28 09:09 Adicionado o script git-docs.sh ao projeto git-tools
- 2026-03-27 20:51 adiciona git-changelog.sh com suporte a datas e filtro de commits automáticos
- 2026-03-27 20:35 adicionado o script git-changelog.sh para gerar relatório
- 2026-03-26 21:59 Adicionado o script git-release.sh
- 2026-03-26 21:46 adiciona o script git-version-inc.sh para calcular o numero da versão de projetos lazarus
- 2026-03-26 21:41 adiciona o script git-version.sh para calcular o numero da versão
- 2026-03-26 21:38 adiciona o scipt git-breaking.sh usado para adicionar atualização que quebra a compatibilidade
- 2026-03-26 21:34 adiciona filtro tree.txt no .gitignore
- 2026-03-26 21:29 adiciona script git-feat.sh
- 2026-03-26 21:17 inicialização do projeto
### 🐛 Correções

- 2026-04-09 10:06 melhora : Quando executado pelo gerenciador de arquivos, o script não informava qual versão foi gerada nem aguardava o usuário prosseguir. Agora mostra a mensagem e pausa com "Pressione algo para continuar".
- 2026-04-09 09:54 corrige : O script git-add-navigator-nautilus.sh não aparecia as 13 opções que apareciam no  git-add-navigator-nemo.sh
- 2026-04-07 21:12 corrige : Corrigido o script git-install.sh pois o mesmo não instalava vários script.
- 2026-03-29 20:33 melhora :  verificam se há repositório antes de executar o script git-fix.sh
- 2026-03-29 17:34 ajusta :  Adicionados dois pontos entre a ação e a mensagem no script git-fix.sh.
- 2026-03-29 17:03 melhora padronizar as mensagens do script git-fix.sh
- 2026-03-29 12:10 Os scripts git-lib.sh, git-reset.sh e git-undo-reset.sh foram ajustados para que restaurassem o número da versão desfeita .
- 2026-03-28 16:01 O nome do script git-add-navigator.sh foi trocado para git-add-navigator-nemo.sh.
- 2026-03-28 14:30 Adicionada a opção de perguntar se inicia o repositório na pasta em que o script git-add-nevigator.sh for executado e a mesma não é repositório.
- 2026-03-27 11:33 Alterado o formato do arquivo version.inc para formato pascal
- 2026-03-26 21:53 Ajuste dos scripts git-version.sh e git-version.sh gerem automaticamente o número da versão
- 2026-03-26 21:30 ignora tree.txt
### 📚 Documentação

- 2026-04-07 22:16 Existe um problema nos script git-add-navigator-nautilus.sh e  git-add-navigator-dolphin.sh ele não fazem o que devem fazer.
- 2026-03-28 18:06 O script git-add-navigator-dolphin está com problemas preciso checar depois.
### ♻️  Refatoração

- 2026-04-09 16:06 reorganiza : Adicionado novas variaves na função _write_header()  dos script  git-add-navigator-nautilus.sh e git-add-navigator-nemo.sh
- 2026-04-09 11:52 reorganiza : O script git-release.sh não mostrava o numero da versão gerada quando executado com o  gerenciador de arquivos.
- 2026-04-09 11:14 renomeia : renomear git-changelog.sh para git-changelog-summary.sh
- 2026-04-09 08:57 extrai : Apaguei arquivos de cópias usadas quando estou testando modificações de um script.
- 2026-04-07 17:25 renomeia : O nome do arquivo git-version-inc.sh foi trocado para git-version0oas-inc.sh
- 2026-03-30 21:07 renomeia : O nome versin.inc foi nomeado para version.pas.inc
### 🔧 Manutenção

- 2026-04-09 15:37 atualiza version-pas-inc para v0.14.3
- 2026-04-09 11:54 atualiza version-pas-inc para v0.14.3
- 2026-04-09 11:50 atualiza version-pas-inc para v0.14.3
- 2026-04-09 11:31 atualiza version-pas-inc para v0.14.3
- 2026-04-09 11:26 atualiza version-pas-inc para v0.14.3
- 2026-04-09 11:15 atualiza version-pas-inc para v0.14.3
- 2026-04-09 10:06 atualiza version-pas-inc para v0.14.3
- 2026-04-09 09:54 atualiza version-pas-inc para v0.14.2
- 2026-04-09 09:52 atualiza version-pas-inc para v0.14.1
- 2026-04-09 08:48 atualiza version-pas-inc para v0.14.1
- 2026-04-07 22:16 atualiza version-pas-inc para v0.14.1
- 2026-04-07 21:12 atualiza version-pas-inc para v0.14.1
- 2026-04-07 21:12 atualiza version-pas-inc para v0.14.1
- 2026-04-07 17:31 atualiza version-pas-inc para v0.14.0
- 2026-04-07 17:23 atualiza version-pas-inc para v0.14.0
- 2026-04-02 17:22 atualiza version.pas.inc para v0.14.0
- 2026-03-30 21:08 atualiza version.pas.inc para v0.14.0
- 2026-03-26 21:20 ignora arquivos md com nome inválido
---
_Gerado automaticamente em 2026-04-09 16:25:35_
