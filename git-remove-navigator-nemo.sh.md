# `git-remove-navigator-nemo.sh` — Remoção da integração git-tools do Nemo

- **Data da versão:** 2026-10-14
- **Versão:** 2.0.0
- **Objetivo da versão:** remover a Nemo Action **Git Tools** e o script mestre criados pelo `git-add-navigator-nemo.sh` 4.0.0, além das instalações antigas em **Scripts** (inclusive o arquivo `Git Tools.sh`)
- **Observações:** a versão acompanha a do `git-remove-navigator-nemo.sh`; se este texto divergir do código, vale o código

## Visão geral

O `git-remove-navigator-nemo.sh` desfaz a integração das ferramentas `git-tools` no gerenciador de arquivos Nemo, removendo o item **Git Tools** do menu de contexto instalado pelo `git-add-navigator-nemo.sh`. Também apaga o que tiver sobrado de versões anteriores no submenu **Scripts**. Opcionalmente, permite desabilitar o menu **Scripts** do Nemo.

## Pré-requisitos

- Bash.
- Nemo instalado (opcional; o script avisa caso não esteja).
- `gsettings` disponível para consultar e alterar as preferências do Nemo (opcional).

## Como utilizar

```bash
./git-remove-navigator-nemo.sh
```

O script não aceita parâmetros. Deve ser executado uma vez para remover a integração.

Durante a execução, o script pode perguntar se você deseja desabilitar o menu **Scripts** do Nemo. Responda `s` para desabilitar ou deixe em branco para manter.

## Como funciona

1. Remove a Nemo Action e o script mestre em `~/.local/share/nemo/actions`.
2. Remove as instalações antigas em `~/.local/share/nemo/scripts`: o arquivo `Git Tools.sh` e os diretórios com variações do nome "Git Tools".
3. Verifica se o menu **Scripts** está habilitado no Nemo via `gsettings`. Se estiver, pergunta ao usuário se deseja desabilitá-lo.
4. Reinicia o Nemo para aplicar as alterações.

### Itens removidos

Em `~/.local/share/nemo/actions`:

- `git-*.nemo_action` (inclui `git-tools.nemo_action`)
- `git-tools-nemo.sh`

Em `~/.local/share/nemo/scripts` (versões anteriores):

- `Git Tools.sh`
- `Git Tools`
- `Git-Tools`
- `git-tools`
- `git tools`
- `GitTools`

## Comportamento e segurança

- **Remoção restrita:** apenas os itens listados em *Itens removidos* são apagados. Outros scripts e actions do Nemo não são afetados.
- **Desabilitação opcional:** a alteração do menu **Scripts** só ocorre se o usuário confirmar com `s`. Vale manter habilitado se você usa scripts de outros programas.
- **Reinício do Nemo:** o script encerra e reabre o Nemo automaticamente. Se o Nemo não estiver disponível, avisa para reiniciar manualmente.
- **`gsettings` ausente:** se o comando não estiver disponível, o script exibe instruções para verificação manual.
- **Sem confirmação para remoção:** os itens Git Tools são removidos sem confirmação prévia.

## Arquivos envolvidos

- `~/.local/share/nemo/actions/` — onde ficam a Nemo Action e o script mestre, que são removidos.
- `~/.local/share/nemo/scripts/` — onde ficavam as instalações antigas, que são removidas.
- Preferência `org.nemo.preferences show-scripts-in-context-menus` — alterada via `gsettings`, se o usuário confirmar.

## Solução de problemas

- **`ℹ Nenhuma Nemo Action Git Tools encontrada`** e **`ℹ Nenhum script Git Tools encontrado em Scripts`** — a integração já foi removida ou nunca foi instalada. Nada a fazer.
- **`⚠ gsettings não disponível`** — desabilite o menu **Scripts** manualmente em **Nemo → Editar → Preferências → Comportamento → Mostrar scripts no menu de contexto**.
- **`⚠ Nemo não encontrado`** — reinicie o Nemo manualmente para aplicar as alterações.
- **Menu Scripts continua aparecendo** — reinicie a sessão ou faça logout e login para garantir que a preferência foi aplicada.
- **O item Git Tools continua no menu do Nemo** — feche todas as janelas do Nemo com `nemo -q` e abra de novo.