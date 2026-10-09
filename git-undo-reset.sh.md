# `git-undo-reset.sh` — Recuperação de commits após `git reset --hard`

**Versão:** 1.2.0

## Visão geral

O `git-undo-reset.sh` recupera commits removidos por um `git reset --hard`, usando o `git reflog` para localizar e restaurar o estado anterior ao reset. Também verifica se a tag de versão esperada existe e oferece recriá-la.

Arquivos que nunca foram commitados não podem ser recuperados por este script.

## Pré-requisitos

- Bash.
- `git-lib.sh` disponível em `/usr/local/bin/git-lib.sh`, com as funções `ask_required`, `ask_confirm` e `load_config`.
- Um repositório Git inicializado no diretório atual (deve existir a pasta `.git`).
- Reflog com entradas suficientes para localizar o estado anterior ao reset.

## Como utilizar

```bash
./git-undo-reset.sh
```

O script não aceita parâmetros. Deve ser executado na raiz do repositório.

Durante a execução, o script pergunta:

1. **Confirmação** do reset — a resposta padrão é `n` (Enter cancela). No terminal, só `n` ou `N` cancelam; qualquer outra resposta, como `nao`, executa o reset.
2. **Recriação da tag** (somente se a tag esperada estiver ausente) — a resposta padrão é `s`.

A **posição do reflog não é perguntada**: o script usa sempre `1` (`HEAD@{1}`), que normalmente é o estado anterior ao reset. Para outra posição, execute manualmente `git reset --hard HEAD@{N}`.

### Exemplo

```bash
./git-undo-reset.sh
```

O script exibe as últimas 15 entradas do reflog, pede confirmação e restaura a posição `1` (`HEAD@{1}`).

## Como funciona

1. Verifica se o diretório `.git` existe.
2. Exibe as últimas 15 entradas do `git reflog --oneline`.
3. Define a posição do reflog como `1`. O script chama `ask_required` com o valor `1` já preenchido e, por isso, não pergunta.
4. Pede confirmação antes de executar `git reset --hard HEAD@{1}`.
5. Executa o reset e, em caso de falha, orienta a tentativa manual.
6. Carrega as configurações com `load_config`.
7. Se `VERSION` estiver definida e a tag `v$VERSION` não existir, pergunta se deseja recriá-la.

## Comportamento e segurança

- **Uso do reflog:** a recuperação depende do histórico de ações do reflog. Entradas antigas podem ser removidas pelo Git com o tempo.
- **Reset destrutivo:** `git reset --hard HEAD@{1}` descarta alterações não commitadas presentes no estado atual.
- **Confirmação:** a operação é cancelada apenas com `n` ou `N` (padrão `n`). No terminal, qualquer outra resposta, como `nao` ou `x`, executa o reset. Com janela (`zenity`), os botões **Sim** e **Não** funcionam normalmente.
- **Arquivos nunca commitados:** não podem ser recuperados. O script avisa sobre essa limitação.
- **Verificação de tag:** a tag só é recriada se o `.gitproject` contiver `VERSION` e a tag correspondente não existir.
- **Recriação de tag:** a tag é recriada no commit atual (após o reset), o que pode não corresponder ao commit original da versão.

## Arquivos envolvidos

- `.git/` — repositório onde o reset e a recriação de tag são executados.
- `.gitproject` — lido por `load_config` para obter a variável `VERSION`.
- `git-lib.sh` — biblioteca externa de funções, exigida em `/usr/local/bin/`.

## Solução de problemas

- **`❌ Nenhum repositório Git encontrado`** — execute o script dentro de um repositório Git inicializado.
- **`❌ Falha na recuperação`** — a posição `1` pode não existir no reflog. Verifique o reflog exibido e execute manualmente `git reset --hard HEAD@{N}` com a posição correta.
- **Posição errada recuperada** — o script usa sempre `HEAD@{1}`. Se houve outras ações depois do reset, essa posição pode não ser a desejada. Verifique as entradas exibidas antes de confirmar e, se necessário, responda `n` e use `git reset --hard HEAD@{N}` manualmente.
- **`⚠ Tag vX.Y.Z ausente`** — a tag não foi recriada. Execute `git-version.sh` com cuidado ou crie a tag manualmente.
- **Arquivos perdidos** — arquivos nunca commitados não podem ser recuperados. Restaure-os a partir de backup, se houver.