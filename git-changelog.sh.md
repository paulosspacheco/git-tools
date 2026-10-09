# `git-changelog.sh` — Geração de changelog a partir do histórico Git

**Versão:** não informada no cabeçalho do script.

## Visão geral

O `git-changelog.sh` gera um changelog em Markdown a partir do histórico de commits do repositório Git atual, agrupando os commits por versão. As versões são identificadas por tags no formato `vX.Y.Z` ou por mensagens de commit no padrão `chore: bump version para vX.Y.Z` (forma em português). O `git-version.sh` atual cria `chore: bump version to vX.Y.Z`, que **não** é reconhecida; nesse caso valem as tags `vX.Y.Z`.

O resultado é exibido em um visualizador de arquivos, por meio da função `view_file` da biblioteca `git-lib.sh`.

## Pré-requisitos

- Bash.
- Estar dentro de um repositório Git.
- `git-lib.sh` disponível em `/usr/local/bin/git-lib.sh`, com as funções `ask_optional`, `notify_info` e `view_file`.

## Como utilizar

```bash
git-changelog.sh [OPÇÕES]
```

### Opções

| Opção | Descrição |
|---|---|
| `-s`, `--since DATA` | Inclui apenas commits a partir de `DATA` (formato `YYYY-MM-DD`). |
| `-h`, `--help` | Exibe a ajuda e encerra. |

### Exemplos

Changelog completo:

```bash
./git-changelog.sh
```

Sem argumentos, o script pergunta interativamente a data inicial. Deixar em branco inclui todo o histórico.

Changelog a partir de uma data:

```bash
./git-changelog.sh --since 2026-04-01
```

## Como funciona

1. Lê os argumentos. Se nenhum for informado, solicita interativamente uma data inicial (opcional).
2. Verifica se o diretório atual está dentro de um repositório Git.
3. Gera o log com o formato `data|refs|mensagem`, filtrando por `--after` quando uma data é informada.
4. Percorre o log e agrupa os commits por versão:
   - Uma tag `vX.Y.Z` ou uma mensagem `chore: bump version para vX.Y.Z` inicia um novo bloco de versão.
   - Os commits seguintes são associados à versão corrente.
   - Se não houver nenhuma versão identificada, os commits são agrupados sob `[versão não definida]`.
5. Extrai o tipo (prefixo antes de `:`) e a descrição de cada commit.
6. Monta o changelog em Markdown e o exibe via `view_file`.

## Comportamento e segurança

- **Somente leitura:** o script não altera o repositório nem cria commits.
- **Arquivos temporários:** o log e o changelog são gravados em arquivos temporários e removidos ao final.
- **Cancelamento:** se o usuário cancelar a solicitação interativa de data, o script encerra sem gerar o changelog.
- **Formato de versão:** apenas tags no padrão `vX.Y.Z` (com `v` minúsculo e três números) são reconhecidas. Outros formatos são tratados como commits comuns.
- **Remoção de aspas:** aspas simples (`'`) são removidas das linhas do log antes do processamento.
- **Commit mais antigo omitido:** o último commit da lista (o mais antigo do intervalo) não aparece no resultado.
- **Commits depois da última tag:** quando existe ao menos uma tag `vX.Y.Z`, os commits mais recentes que a última tag (ainda sem versão) não aparecem. Para vê-los, use o `git-changelog-summary.sh`.
- **Terminal sem `DISPLAY`:** em terminal puro (console de texto ou SSH sem ambiente gráfico), onde a variável `DISPLAY` não existe, o script termina com `DISPLAY: unbound variable`, mensagem vinda do `git-lib.sh`. Contorno: `DISPLAY= WAYLAND_DISPLAY= git-changelog.sh`.
- **`--since` sem data:** o script termina com erro, sem mensagem.

## Arquivos envolvidos

- Arquivo temporário com o log do Git (removido ao final).
- Arquivo temporário em `/tmp/changelog-XXXX.md` com o changelog gerado (removido após a exibição).
- `git-lib.sh` — biblioteca externa, exigida em `/usr/local/bin/`.

## Solução de problemas

- **`Erro: Este não é um repositório Git`** — execute o script dentro de um repositório Git.
- **`Nenhum commit encontrado no intervalo especificado`** — a data informada pode ser posterior a todos os commits. Ajuste ou omita o `--since`.
- **Argumento desconhecido** — o script exibe a ajuda e encerra. Verifique a grafia das opções.
- **Versões não aparecem agrupadas** — confirme se as tags seguem o padrão `vX.Y.Z`. Commits `chore: bump version to vX.Y.Z` não são reconhecidos, só os `chore: bump version para vX.Y.Z`.
- **Faltam os commits mais recentes ou o mais antigo** — veja os itens de *Comportamento e segurança* sobre commits depois da última tag e sobre o commit mais antigo.
- **`DISPLAY: unbound variable`** — veja o item sobre terminal sem `DISPLAY`.
- **Erro ao carregar `git-lib.sh`** — verifique se o arquivo existe em `/usr/local/bin/git-lib.sh`.