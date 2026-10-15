# `git-undo-reset.sh` — Recupera commits desfeitos pelo `git-reset`

**Versão:** 1.3.0  
**Data:** 2026-10-15

**Objetivo da versão:**

- Mostrar numa lista os commits desfeitos, com data e mensagem, e deixar escolher qual recuperar
- Devolver o commit original quando nada foi feito depois do reset, e copiá-lo por cima (cherry-pick) quando houve commits depois, sem perder nada
- Em caso de conflito, desistir da tentativa e deixar a pasta como estava
- Recriar a tag no commit que marcou a versão, não no commit atual
- Mostrar as mensagens em janela, para quem usa o menu do gerenciador de arquivos

**Observações de uso:**

- Executar na raiz do repositório (pasta com `.git`), sem alterações não commitadas
- Arquivos fora do Git não são tocados nem impedem a recuperação
- O Git apaga do histórico as entradas antigas com o tempo; recupere logo depois do engano

---

## Visão geral

O `git-undo-reset.sh` traz de volta commits que saíram da pasta por um `git-reset`. Ele procura no histórico de ações do Git (o reflog) os commits que não estão mais na pasta, mostra numa lista e recupera o escolhido.

Até a versão 1.2.0, ele voltava sempre para o estado anterior à última ação. Isso só funcionava se o reset fosse a última coisa feita. Agora a pessoa escolhe o commit, e o script decide sozinho como recuperar.

Ele não recupera arquivos que nunca foram commitados.

## Pré-requisitos

- Bash e Git.
- `git-lib.sh` em `/usr/local/bin/git-lib.sh`.
- Um repositório Git na pasta atual, sem alterações não commitadas.

## Como utilizar

Pelo menu do gerenciador de arquivos, escolha **Recuperar commit desfeito (undo reset)**. No terminal, dentro da pasta do projeto:

```bash
git-undo-reset
```

1. **Escolha o commit.** A lista mostra até 15 commits desfeitos, do mais recente para o mais antigo, e o mais recente já vem marcado. No terminal, digite o número; Enter escolhe o 1.
2. **Confira o plano e confirme.** A janela explica o que vai acontecer. O **Não** é o padrão; no terminal, Enter cancela e só `s` ou `sim` confirmam.
3. **Tag de versão** (só se faltar a tag da versão do `.gitproject`): confirme se ela deve ser recriada.

## Como funciona

1. Confere se a pasta tem `.git`, se há commits e se não há alterações não commitadas.
2. Percorre o histórico de ações e separa os commits que não estão na pasta. Ficam de fora os commits cujo conteúdo já está nela, por exemplo os que já foram recuperados com cherry-pick.
3. Mostra a lista e recebe a escolha.
4. Escolhe o jeito de recuperar:

| Situação | O que faz | Resultado |
|----------|-----------|-----------|
| Nada foi feito depois do reset | Avança a pasta até o commit escolhido | O commit volta com o código original, e a tag continua válida |
| Houve commits depois do reset | Copia os commits desfeitos por cima dos atuais (`git cherry-pick`) | Nada se perde; os commits copiados ganham códigos novos |

5. Mostra o plano e pede confirmação.
6. Recupera. Se o cherry-pick der conflito, desiste da tentativa (`git cherry-pick --abort`) e a pasta fica como estava.
7. Se o `.gitproject` indica uma versão sem tag, procura o commit `chore: bump version to vX.Y.Z` e oferece recriar a tag nele.
8. Mostra o resultado numa janela.

## Comportamento e segurança

- **Nada é apagado:** a recuperação só acrescenta commits. O que foi feito depois do reset é mantido.
- **Commits encadeados:** recuperar um commit traz junto os commits desfeitos que vêm antes dele.
- **Pasta com alterações:** o script para e pede o commit delas antes, para não misturar as mudanças.
- **Conflito:** quando o commit desfeito e os commits posteriores mexem nas mesmas linhas, o script não tenta resolver. A pasta fica como estava.
- **GitHub:** a recuperação só acrescenta commits, então o próximo `git-github` envia normalmente. Se um commit já enviado foi desfeito, recuperá-lo deixa a pasta de novo igual ao GitHub.
- **Histórico limitado:** o Git apaga com o tempo as entradas antigas do histórico de ações. Commits muito antigos podem não aparecer mais.

## Arquivos envolvidos

- `.git/` — histórico de ações (reflog), commits e tags.
- `.gitproject` — versão usada para conferir a tag.
- `git-lib.sh` — funções de janela e leitura do `.gitproject`.

## Solução de problemas

- **`❌ Há alterações não commitadas nesta pasta`** — faça o commit delas e rode de novo. Confira com o **Ver estado da pasta (state)**.
- **`ℹ️ Não há commits desfeitos para recuperar`** — tudo o que está no histórico recente já está na pasta.
- **`❌ Não foi possível recuperar automaticamente`** — houve conflito entre o commit desfeito e o que veio depois. A pasta não mudou. A recuperação, nesse caso, precisa ser feita à mão, juntando as mudanças.
- **`⚠ Tag ... ausente`** — a tag não foi recriada. Rode o `git-version` com cuidado.