# `git-uninstall.sh` — Remoção global das ferramentas Git e integrações

- **Data da versão:** 2026-10-14
- **Versão:** 2.2.0
- **Objetivo da versão:** remover do Nemo a Nemo Action **Git Tools** e o script mestre criados pelo `git-add-navigator-nemo.sh` 4.0.0, além do que restou das instalações antigas em **Scripts**
- **Observações:** a versão acompanha a do `git-uninstall.sh`; se este texto divergir do código, vale o código

## Visão geral

O `git-uninstall.sh` remove globalmente as ferramentas `git-tools` instaladas em `/usr/local/bin/`, bem como as integrações com gerenciadores de arquivos, aliases do `~/.bashrc` e configurações do Lazarus.

A versão 2.2.0 passa a remover o item **Git Tools** do Nemo, instalado como Nemo Action pelo `git-add-navigator-nemo.sh` 4.0.0, além do que restou das instalações antigas no submenu **Scripts**. A ordem de remoção dos scripts (primeiro coleta a lista, depois remove) vem da versão 2.1.0.

## Pré-requisitos

- Bash.
- Permissão de `sudo` para remover arquivos de `/usr/local/bin/`.
- Opcionalmente, `zenity` ou `kdialog` para seleção manual do `environmentoptions.xml`.

## Como utilizar

```bash
./git-uninstall.sh
```

O script não aceita parâmetros. Execute-o como usuário comum, sem `sudo`: ele pede `sudo` internamente só para remover arquivos de `/usr/local/bin/`, e o `~/.bashrc` e os menus que ele limpa são os do seu usuário. Depois, execute `source ~/.bashrc` para limpar os aliases da sessão atual.

O script solicita confirmação apenas em alguns casos:

- Seleção manual do `environmentoptions.xml`, se não for encontrado automaticamente.
- Escolha de localizar o arquivo manualmente, se `zenity` ou `kdialog` estiverem disponíveis.

## Como funciona

1. **Coleta e remoção de scripts:**
   - Monta a lista de arquivos a remover combinando a lista fixa `EXTRA_FILES` com os scripts listados no `git-tools.conf` instalado em `/usr/local/bin/`.
   - Remove duplicatas.
   - Remove cada arquivo de `/usr/local/bin/` com `sudo rm -f`.
2. **Remoção do XML do Lazarus:**
   - Remove `lazarus.git-tools.xml` do diretório do script, se existir.
3. **Reversão do `environmentoptions.xml`:**
   - Procura o arquivo em locais comuns (`~/.lazarus/`, `/etc/lazarus/` e pastas `config_lazarus` dentro de `~/Lazarus/`) e, se necessário, via `find` em `$HOME` e `/mnt`. Usa apenas o primeiro arquivo encontrado.
   - Se um backup `.bak` existir, restaura a partir dele.
   - Caso contrário, remove o bloco `<ExternalTools>` diretamente com `sed`.
   - Se não encontrar automaticamente, oferece seleção manual via `zenity` ou `kdialog`.
4. **Remoção de aliases do `~/.bashrc`:**
   - Cria um backup `~/.bashrc.bak-uninstall`.
   - Remove blocos de aliases nos formatos novo e antigo.
   - Remove linhas remanescentes que comecem com `alias git-` ou `alias version-pas-`.
5. **Remoção de integrações com gerenciadores de arquivos:**
   - Nemo: remove as actions `~/.local/share/nemo/actions/git-*.nemo_action`, o script mestre `~/.local/share/nemo/actions/git-tools-nemo.sh` e, das instalações antigas, o arquivo `~/.local/share/nemo/scripts/Git Tools.sh` e a pasta `~/.local/share/nemo/scripts/Git Tools`.
   - Nautilus: remove `~/.local/share/nautilus/scripts/Git Tools`.
   - Dolphin: remove `~/.local/share/git-tools` e `~/.local/share/kio/servicemenus/git-tools.desktop`, e atualiza o cache do KDE com `kbuildsycoca5` se disponível.

## Comportamento e segurança

- **Remoção com `sudo`:** os arquivos em `/usr/local/bin/` são removidos com `sudo rm -f`, sem confirmação individual.
- **Backup do `.bashrc`:** o arquivo `~/.bashrc.bak-uninstall` é criado antes das alterações.
- **Restauração do Lazarus:** se o backup `.bak` existir, ele é usado; caso contrário, o bloco `<ExternalTools>` é removido diretamente do XML. Essa remoção pode afetar outras ferramentas externas configuradas no Lazarus.
- **Lista fixa de arquivos:** os arquivos em `EXTRA_FILES` são sempre removidos, mesmo que o `git-tools.conf` não exista.
- **Sem confirmação global:** o script não pede confirmação antes de iniciar a desinstalação. A execução remove imediatamente os arquivos listados.
- **Aliases:** a remoção de aliases `git-*` e `version-pas-*` pode afetar aliases definidos por outros programas com o mesmo prefixo.
- **Actions do Nemo:** são removidas todas as actions `git-*.nemo_action` do usuário. Uma action de outro programa com esse prefixo também seria apagada. Scripts e actions com outros nomes não são afetados.

## Arquivos envolvidos

- Todos os scripts listados no `git-tools.conf` instalado (`git-ini.sh`, `git-feat.sh`, `git-github.sh` etc.) — removidos de `/usr/local/bin/`.
- `/usr/local/bin/git-tools.conf`, `git-lib.sh`, `git-config.sh`, `git-hook.sh`, `git-add-navigator-nemo.sh`, `git-add-navigator-nautilus.sh` e `git-add-navigator-dolphin.sh` — removidos.
- `lazarus.git-tools.xml` — removido, se existir no diretório do script.
- `environmentoptions.xml` — restaurado a partir de backup ou com o bloco `<ExternalTools>` removido.
- `~/.bashrc` — aliases removidos; backup em `~/.bashrc.bak-uninstall`.
- `~/.local/share/nemo/actions/git-tools.nemo_action` e demais `git-*.nemo_action` — removidos.
- `~/.local/share/nemo/actions/git-tools-nemo.sh` — removido.
- `~/.local/share/nemo/scripts/Git Tools.sh` e `~/.local/share/nemo/scripts/Git Tools` — removidos (instalações antigas).
- `~/.local/share/nautilus/scripts/Git Tools` — removido.
- `~/.local/share/git-tools` — removido.
- `~/.local/share/kio/servicemenus/git-tools.desktop` — removido.

## Solução de problemas

- **`⚠ /usr/local/bin/git-tools.conf não encontrado`** — apenas os arquivos da lista fixa serão removidos. Scripts adicionais instalados pelo `git-install.sh` podem permanecer em `/usr/local/bin/`.
- **`⚠ Não foi possível localizar automaticamente o environmentoptions.xml`** — forneça o caminho manualmente quando solicitado, ou use `zenity`/`kdialog` para selecioná-lo.
- **`⚠ Backup não encontrado`** — o bloco `<ExternalTools>` será removido diretamente. Se outras ferramentas externas estiverem configuradas, elas também serão removidas.
- **Aliases permanecem ativos na sessão atual** — execute `source ~/.bashrc` ou abra um novo terminal.
- **O item Git Tools continua aparecendo no Nemo** — feche todas as janelas do Nemo com `nemo -q` e abra de novo.
- **Integração com Dolphin ainda visível** — reinicie o Dolphin ou faça logout e login.
- **Scripts permanecem em `/usr/local/bin/`** — verifique se o usuário tem permissão de `sudo` e se não houve erro durante a remoção.