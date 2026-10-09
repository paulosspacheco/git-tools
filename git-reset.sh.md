# `git-reset.sh` — Desfaz o último commit e descarta alterações

**Versão:** 1.3.1  
**Data:** 2026-10-09

## Visão geral

O `git-reset.sh` reverte o repositório para o estado do penúltimo commit, descartando permanentemente todas as alterações não commitadas. Ele também detecta se o commit removido era um bump de versão e oferece remover a tag correspondente.

O commit removido pode ser recuperado com `git-undo-reset.sh`. No entanto, arquivos que nunca foram commitados serão perdidos permanentemente.

## Pré-requisitos

- Bash.
- `git-lib.sh` disponível em `/usr/local/bin/git-lib.sh`, com a função `ask_confirm`.
- Um repositório Git inicializado no diretório atual (deve existir a pasta `.git`).
- Pelo menos dois commits no histórico (o script usa `HEAD~1`). Com apenas um, o script avisa e encerra com código `1`, sem alterar nada.

## Como utilizar

```bash
./git-reset.sh
```

O script não aceita parâmetros. Deve ser executado na raiz do repositório.

Durante a execução, o script pergunta:

1. **Confirmação inicial** — a resposta padrão é `n` (Enter cancela). Responda `s` ou `sim` para prosseguir. Qualquer outra resposta, como `nao` ou `x`, cancela.
2. **Remoção da tag** (somente se o commit removido for um bump de versão) — a resposta padrão é `s`. Responda `s` ou `sim` para remover; qualquer outra resposta mantém a tag.

## Como funciona

1. Verifica se o diretório `.git` existe.
2. Verifica se existe um commit anterior (`HEAD~1`). Se não existir, avisa e encerra com código `1`.
3. Exibe um aviso detalhado sobre o que será feito.
4. Pede confirmação. Só `s` ou `sim` (maiúsculas ou minúsculas) prosseguem; qualquer outra resposta cancela.
5. Captura a mensagem do último commit e a última tag antes do reset.
6. Executa `git reset --hard HEAD~1`, descartando o último commit e todas as alterações não commitadas. Se o `git reset` falhar, informa o erro e encerra com código `1`.
7. Se a mensagem do commit removido começar com `chore: bump version` e houver alguma tag, pergunta se a tag correspondente deve ser removida.
8. Remove a tag, se confirmado.

## Comportamento e segurança

- **Operação destrutiva:** `git reset --hard` descarta permanentemente as alterações não commitadas. Não há forma de recuperá-las.
- **Commit removido é recuperável:** o commit apagado pode ser restaurado com `git-undo-reset.sh`, desde que o script esteja disponível.
- **Arquivos nunca commitados são perdidos:** arquivos que nunca passaram por um commit não podem ser recuperados.
- **Confirmação obrigatória:** a operação só prossegue com `s` ou `sim`. Enter, `n` ou qualquer outra resposta cancelam, e nada é alterado. Com janela (`zenity`), use os botões **Sim** e **Não**.
- **Falha do reset:** se o `git reset --hard` falhar, o script não informa sucesso e não oferece remover a tag.
- **Detecção de bump de versão:** a verificação é feita pela mensagem do commit (`chore: bump version...`). Outros formatos de bump não são reconhecidos.
- **Remoção de tag:** a tag sugerida é a última em ordem de versão (`git tag --sort=-version:refname | head -1`). Se o commit removido não estiver associado a essa tag, a remoção pode afetar outra versão.

## Arquivos envolvidos

- `.git/` — repositório onde o reset e a remoção de tag são executados.
- `git-lib.sh` — biblioteca externa de funções, exigida em `/usr/local/bin/`.

## Solução de problemas

- **`❌ Nenhum repositório Git encontrado`** — execute o script dentro de um repositório Git inicializado.
- **`❌ O repositório não tem um commit anterior para voltar (HEAD~1)`** — o repositório tem apenas um commit. Não é possível desfazer o último commit com este script.
- **`❌ Falha ao executar git reset --hard HEAD~1`** — o Git recusou o reset. Leia a mensagem do Git exibida logo acima.
- **`⚠ Operação cancelada pelo usuário`** — a resposta à confirmação não foi `s` nem `sim` (inclusive Enter, que assume `n`). Nenhuma alteração foi feita.
- **`⚠ Tag ... mantida`** — a tag não foi removida. Verifique manualmente se a versão continua consistente com o estado atual do projeto.
- **Recuperar o commit removido** — use `git-undo-reset.sh`, se disponível no ambiente.
- **Arquivos não commitados perdidos** — não há recuperação possível por meio deste script.