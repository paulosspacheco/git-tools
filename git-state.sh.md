# `git-state.sh` — Mostra o estado da pasta antes de voltar atrás

**Versão:** 1.2.1  
**Data:** 2026-10-15

**Objetivo da versão:**

- Mostrar nomes de arquivo com acento ou espaço como eles são
- Usar fonte de largura fixa na janela, para alinhar código, data e mensagem
- Com o reset bloqueado, não dizer nos títulos o que o `git-reset` faria com as alterações
- Deixar uma única linha em branco entre os grupos de arquivos

**Observações de uso:**

- Executar na raiz do repositório (pasta com `.git`)
- Só mostra informações: não altera arquivos, commits nem tags
- No `git-tools.conf`, fica logo antes do `git-reset.sh`, para aparecer acima dele no menu
- O `git-reset.sh` usa este script como tela de confirmação

---

## Visão geral

O `git-state.sh` mostra, numa janela, tudo o que é preciso saber antes de voltar atrás: em que pasta você está, a versão, se o trabalho já foi enviado ao GitHub, os últimos commits, o que ainda não foi commitado e o que o `git-reset` faria.

Ele existe porque o git-tools roda pelo menu do gerenciador de arquivos, onde a saída do terminal não aparece. Sem ele, quem usa o menu confirmaria o reset sem ver o estado da pasta.

## Pré-requisitos

- Bash e Git.
- `git-lib.sh` em `/usr/local/bin/git-lib.sh`.
- Para a janela: `zenity` e ambiente gráfico. Sem eles, o relatório é impresso no terminal.

## Como utilizar

Pelo menu do gerenciador de arquivos, escolha **Ver estado da pasta (state)**. No terminal, dentro da pasta do projeto:

```bash
git-state
```

O modo `--reset` é usado pelo `git-reset.sh` e não precisa ser chamado à mão:

```bash
git-state.sh --reset
```

## O que o relatório mostra

| Linha | Significado |
|-------|-------------|
| 📁 Pasta | A pasta onde o comando foi executado |
| 🌿 Ramo | O ramo atual, normalmente `main` |
| 🏷 Versão no .gitproject | A versão gravada no `.gitproject` (só aparece se o arquivo existir) |
| 🏷 Última tag | A tag de versão mais alta |
| ☁️ GitHub | A situação do envio (veja a tabela abaixo) |
| 🕘 Últimos commits | Os 5 commits mais recentes, com código, data e hora e a mensagem cortada em 70 caracteres |
| Alterações | Os arquivos fora de commit, separados em três grupos |
| ↩ ou ⛔ | O que o `git-reset` faria agora, ou por que ele está bloqueado |

### Situação do GitHub

| Mensagem | Significado |
|----------|-------------|
| esta pasta ainda não foi enviada | Nunca houve envio com o `git-github` |
| em dia (conforme o último envio) | Tudo o que está na pasta já está no GitHub |
| N commits ainda não enviados | Há commits só na sua máquina; o `git-github` os envia |
| tem N commits que esta pasta não tem | O GitHub está à frente. Se foi um `git-reset` de commit já enviado, o `git-undo-reset` devolve |

Quando a pasta não aponta para o GitHub, a linha diz **servidor** no lugar de **GitHub**.

### Grupos de alterações

| Grupo | O que o `git-reset` faz com ele |
|-------|---------------------------------|
| ✏️ Alterados e não commitados | Descarta as alterações |
| ⚠️ Novos, adicionados e nunca commitados | Apaga os arquivos |
| 📄 Fora do Git | Não mexe |

Quando o reset está bloqueado, os títulos aparecem sem a parte entre parênteses, porque o reset não vai acontecer.

## Como funciona

1. Confere se a pasta tem `.git` e lê o `.gitproject`.
2. Lê o ramo, a última tag e a situação do envio, comparando a pasta com o que o Git guardou no último envio ao GitHub.
3. Lê as alterações com `git status` e separa os três grupos.
4. Decide se o reset é permitido: precisa haver um commit anterior, e o último commit não pode estar no GitHub.
5. Monta o relatório e o mostra numa janela de texto ou no terminal.

### Modo `--reset`

Com o reset permitido, a janela traz a caixa **Conferi o estado da pasta e quero desfazer o último commit** e os botões **Desfazer** e **Cancelar**. O **Desfazer** só libera depois de marcar a caixa. No terminal, a pergunta vem abaixo do relatório: Enter cancela e só `s` ou `sim` confirmam.

Com o reset bloqueado, a janela só mostra o relatório com o aviso ⛔.

| Código de saída | Significado |
|-----------------|-------------|
| `0` | Confirmou o reset |
| `1` | Cancelou |
| `2` | Reset não permitido |

## Comportamento e segurança

- **Só leitura:** o script não altera nada na pasta nem no GitHub.
- **Sem internet:** a situação do GitHub vem do que o Git guardou no último envio. Mudanças feitas no GitHub depois disso, por outro computador ou pelo site, não aparecem.
- **Commit já enviado:** o reset fica bloqueado, porque desfazer só na sua máquina deixaria a pasta diferente do GitHub e o próximo envio falharia. O caminho certo é um commit novo com a correção (`git-fix` ou `git-docs`). Se for uma versão publicada, lance a próxima.
- **Pasta nunca enviada:** o reset é permitido, porque não há nada no GitHub para ficar diferente.
- **Mensagens cortadas:** o corte em 70 caracteres é só na tela. A mensagem completa continua no histórico.

## Arquivos envolvidos

- `.git/` — de onde vêm commits, tags e alterações.
- `.gitproject` — de onde vem a versão.
- `git-lib.sh` — funções de janela e leitura do `.gitproject`.

## Solução de problemas

- **`❌ Nenhum repositório Git encontrado`** — execute na pasta que contém `.git`, ou rode o `git-ini` antes.
- **A linha do GitHub diz "em dia", mas houve mudanças no site** — o relatório usa o último envio. Rode o `git-github`; se o GitHub tiver algo novo, ele avisa e explica o que fazer.
- **Arquivos que você não reconhece em "Fora do Git"** — confira o conteúdo antes de apagar. Cópias de emergência do editor nano (`.save`) podem ser evitadas acrescentando `*.save` ao `.gitignore`.