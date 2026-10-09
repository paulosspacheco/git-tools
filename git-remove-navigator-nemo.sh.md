# `git-remove-navigator-nemo.sh` — Remoção da integração git-tools do Nemo

**Versão:** 1.0.0

## Visão geral

O `git-remove-navigator-nemo.sh` desfaz a integração das ferramentas `git-tools` no gerenciador de arquivos Nemo, removendo os wrappers instalados pelo `git-add-navigator-nemo.sh`. Opcionalmente, também permite desabilitar o menu **Scripts** do Nemo.

**Atenção:** a versão atual do `git-add-navigator-nemo.sh` (3.2.0) instala um único arquivo, `~/.local/share/nemo/scripts/Git Tools.sh`, e este script remove apenas **diretórios**. O arquivo `Git Tools.sh` não é apagado (veja *Solução de problemas*).

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

1. Remove os diretórios com variações do nome "Git Tools" em `~/.local/share/nemo/scripts`.
2. Verifica se o menu **Scripts** está habilitado no Nemo via `gsettings`. Se estiver, pergunta ao usuário se deseja desabilitá-lo.
3. Reinicia o Nemo para aplicar as alterações.

### Diretórios removidos

- `~/.local/share/nemo/scripts/Git Tools`
- `~/.local/share/nemo/scripts/Git-Tools`
- `~/.local/share/nemo/scripts/git-tools`
- `~/.local/share/nemo/scripts/git tools`
- `~/.local/share/nemo/scripts/GitTools`

## Comportamento e segurança

- **Remoção restrita:** apenas os diretórios com variações do nome "Git Tools" são removidos. Outros scripts do Nemo não são afetados.
- **Desabilitação opcional:** a alteração do menu **Scripts** só ocorre se o usuário confirmar com `s`.
- **Reinício do Nemo:** o script encerra e reabre o Nemo automaticamente. Se o Nemo não estiver disponível, avisa para reiniciar manualmente.
- **`gsettings` ausente:** se o comando não estiver disponível, o script exibe instruções para verificação manual.
- **Sem confirmação para remoção:** os diretórios Git Tools são removidos sem confirmação prévia.
- **Arquivo `Git Tools.sh` preservado:** o script mestre criado pelas versões atuais da integração é um arquivo, e não é removido por este script.

## Arquivos envolvidos

- `~/.local/share/nemo/scripts/` — diretório onde os wrappers estão instalados e são removidos.
- Preferência `org.nemo.preferences show-scripts-in-context-menus` — alterada via `gsettings`, se o usuário confirmar.

## Solução de problemas

- **`ℹ Nenhum diretório Git Tools encontrado`** — a integração já foi removida ou nunca foi instalada. Nada a fazer.
- **`⚠ gsettings não disponível`** — desabilite o menu **Scripts** manualmente em **Nemo → Editar → Preferências → Comportamento → Mostrar scripts no menu de contexto**.
- **`⚠ Nemo não encontrado`** — reinicie o Nemo manualmente para aplicar as alterações.
- **Menu Scripts continua aparecendo** — reinicie a sessão ou faça logout e login para garantir que a preferência foi aplicada.
- **O item Git Tools continua no menu do Nemo** — apague o script mestre: `rm "$HOME/.local/share/nemo/scripts/Git Tools.sh"`.