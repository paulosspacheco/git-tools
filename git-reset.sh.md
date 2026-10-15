# `git-reset.sh` — Desfaz o último commit e descarta alterações

**Versão:** 1.4.0  
**Data:** 2026-10-15

**Objetivo da versão:**

- Usar o relatório do `git-state.sh` como confirmação: a pessoa vê o que será descartado e qual commit será desfeito antes de decidir
- Não desfazer um commit que já está no GitHub, porque isso deixaria a pasta diferente do GitHub e faria o próximo envio falhar
- Mostrar o resultado em janela, para quem usa o menu do gerenciador de arquivos

**Observações de uso:**

- Executar na raiz do repositório (pasta com `.git`), com ao menos 2 commits
- Depende do `git-state.sh` instalado em `/usr/local/bin`
- Com janela, o botão **Desfazer** só libera depois de marcar a caixa de confirmação; no terminal, Enter cancela e só `s` ou `sim` confirmam

---

## Visão geral

O `git-reset.sh` volta o repositório para o penúltimo commit e descarta as alterações não commitadas. Antes de fazer qualquer coisa, ele mostra o estado da pasta com o `git-state.sh`. Se o último commit já foi enviado ao GitHub, ele não deixa desfazer.

O commit desfeito pode ser recuperado com o `git-undo-reset.sh`.

## Pré-requisitos

- Bash e Git.
- `git-lib.sh` e `git-state.sh` em `/usr/local/bin`.
- Um repositório Git na pasta atual, com pelo menos dois commits.

## Como utilizar

Pelo menu do gerenciador de arquivos, escolha **Desfazer último commit (reset)**. No terminal, dentro da pasta do projeto:

```bash
git-reset
```

O script não aceita parâmetros.

Recomendação: antes de desfazer, olhe o **Ver estado da pasta (state)**. O próprio reset mostra o mesmo relatório, mas olhar antes ajuda a decidir com calma.

## Como funciona

1. Confere se a pasta tem `.git` e se o `git-state.sh` está instalado.
2. Chama o `git-state.sh --reset`, que mostra o relatório e:
   - **se o reset é permitido:** pede a confirmação (caixa e botão **Desfazer** na janela, `s` ou `sim` no terminal);
   - **se o último commit já está no GitHub:** mostra o aviso ⛔ e encerra sem alterar nada;
   - **se não há commit anterior:** mostra o aviso ↩ e encerra sem alterar nada.
3. Guarda a mensagem do último commit e a última tag.
4. Executa `git reset --hard HEAD~1`.
5. Se o commit desfeito era uma marcação de versão (`chore: bump version`), pergunta se a tag deve ser removida.
6. Mostra o resultado numa janela: o commit desfeito, a situação da tag e o lembrete do `git-undo-reset`.

## O que é descartado

| Situação do arquivo | O que acontece |
|---------------------|----------------|
| Alterado e não commitado | As alterações são descartadas e não podem ser recuperadas |
| Novo, adicionado e nunca commitado | O arquivo é apagado e não pode ser recuperado |
| Fora do Git (nunca adicionado) | Não é tocado |
| Conteúdo do commit desfeito | Sai da pasta, mas pode ser recuperado com o `git-undo-reset` |

## Comportamento e segurança

- **Commit já enviado:** o reset é bloqueado. Para corrigir algo já enviado, faça um commit novo com a correção (`git-fix` ou `git-docs`). Para uma versão já publicada, lance a próxima versão em vez de voltar.
- **Verificação sem internet:** o script usa o que o Git guardou no último envio. Uma pasta nunca enviada pode ser desfeita à vontade.
- **Confirmação protegida:** na janela, o **Desfazer** fica desativado até marcar a caixa; um Enter apressado não executa o reset.
- **Tag de versão:** a tag sugerida para remoção é a última em ordem de versão. Ela só é oferecida quando o commit desfeito é uma marcação de versão.
- **Falha do reset:** se o `git reset --hard` falhar, o script avisa e não oferece remover a tag.

## Arquivos envolvidos

- `.git/` — onde o reset e a remoção da tag acontecem.
- `git-state.sh` — relatório e confirmação.
- `git-lib.sh` — funções de janela e confirmação.

## Solução de problemas

- **`❌ Nenhum repositório Git encontrado`** — execute na pasta que contém `.git`.
- **`❌ git-state.sh não encontrado em /usr/local/bin`** — rode o `git-install.sh` de novo.
- **⛔ O git-reset não pode desfazer o último commit** — o commit já está no GitHub. Nada foi alterado.
- **↩ Não há commit anterior para voltar** — a pasta tem um único commit. Nada foi alterado.
- **`⚠ Operação cancelada pelo usuário`** — a confirmação não foi dada. Nada foi alterado.
- **`⚠ Tag ... mantida`** — a tag continua apontando para um commit que saiu da pasta. Rode o `git-version` com cuidado.
- **Desfiz por engano** — use o **Recuperar commit desfeito (undo reset)**.