# `mover-para-semuso.sh` — Move para `semuso/` os arquivos fora do projeto

**Versão:** 1.0.0  
**Data da versão:** 2026-10-09

## Visão geral

O `mover-para-semuso.sh` tira da raiz do projeto os arquivos de depuração, de configuração pessoal e gerados, sem apagar nada. Ele os move para a pasta `semuso/` e acrescenta essa pasta ao `.gitignore`.

É um utilitário de manutenção do repositório do git-tools. Ele não está no `git-tools.conf`, portanto não é instalado em `/usr/local/bin` e não ganha alias nem item de menu.

## Pré-requisitos

- Bash.
- `git-lib.sh` na mesma pasta do script.
- `zenity` (opcional): havendo ambiente gráfico, a confirmação aparece em uma janela. Caso contrário, no terminal.
- Git (opcional): em um repositório, os arquivos já versionados saem do controle do Git.

## Como utilizar

Execute a partir da pasta do projeto, onde estão o script e o `git-lib.sh`:

```bash
./mover-para-semuso.sh --simular   # só mostra o que seria movido
./mover-para-semuso.sh             # pede confirmação e move
```

| Opção | Efeito |
|-------|--------|
| `-n`, `--simular` | Lista os arquivos que seriam movidos e encerra, sem alterar nada e sem pedir confirmação |

Qualquer outro argumento exibe o modo de uso e encerra com código `1`.

### Exemplo

```text
$ ./mover-para-semuso.sh --simular
Seriam movidos para semuso/:
  • install.log
  • tree.txt
  • test-version.sh
```

Ao executar de verdade e confirmar:

```text
✔ 3 arquivo(s) movido(s) para semuso/

1 saíram do controle do Git. Faça o commit com git-refactor (reorganiza).
```

## Arquivos movidos

A lista fica na variável `ARQUIVOS`, no início do script. Edite-a para incluir ou retirar nomes:

- `install.log`
- `tree.txt`
- `check-timeline.sh`
- `test-version.sh`
- `git-add-navigator-nemo-versao-menor-que_5.sh`
- `git-tools.md`
- `git-tools.code-workspace`
- `resumo.jpeg`

Só os que existem na pasta são considerados. Se nenhum existir, o script avisa `Nenhum arquivo para mover.` e encerra.

## Como funciona

1. Muda para a pasta onde o próprio script está e carrega o `git-lib.sh`.
2. Procura, nessa pasta, os arquivos da lista `ARQUIVOS`.
3. Com `--simular`, mostra a lista e encerra.
4. Mostra a lista e pede confirmação. No terminal, `s` ou Enter continuam (o padrão é `s`); qualquer outra resposta cancela. Com janela, use os botões **Sim** e **Não**.
5. Cria a pasta `semuso/`.
6. Para cada arquivo:
   - se já existir um arquivo com o mesmo nome em `semuso/`, avisa e mantém o original onde está;
   - se o arquivo estiver no Git, retira-o do controle com `git rm --cached`;
   - move o arquivo para `semuso/`.
7. Acrescenta `semuso/` ao `.gitignore`, se essa linha ainda não existir. Se o `.gitignore` não existir, ele é criado.
8. Mostra um resumo: quantos foram movidos, quantos já existiam no destino e quantos saíram do controle do Git.

## Comportamento e segurança

- **Nada é apagado:** os arquivos são movidos, não removidos. Para devolver um: `mv semuso/arquivo .`. Se ele era versionado, rode depois `git add arquivo`.
- **Pasta do script:** o script age na pasta onde ele está, mesmo quando chamado de outra pasta.
- **Commit pendente:** os arquivos que estavam no Git ficam como removidos do índice (`git rm --cached`). É preciso fazer o commit para registrar a mudança, por exemplo com `git-refactor` (ação `reorganiza`).
- **`.gitignore` alterado:** `semuso/` passa a ser ignorada pelo Git, então o que está nela não é versionado.
- **Confirmação:** a lista de arquivos é mostrada antes de qualquer alteração. Como Enter equivale a `s`, leia a lista antes de pressionar Enter.
- **Sem commit automático:** o script não faz commit.
- **Sem sobrescrita:** um arquivo que já exista em `semuso/` não é substituído.

## Arquivos envolvidos

- `semuso/` — pasta criada na pasta do script, recebe os arquivos.
- `.gitignore` — recebe a linha `semuso/`.
- Índice do Git — os arquivos versionados são retirados dele com `git rm --cached`.
- `git-lib.sh` — biblioteca carregada da mesma pasta do script.

## Solução de problemas

- **`Nenhum arquivo para mover.`** — nenhum arquivo da lista existe na pasta. Confira os nomes em `ARQUIVOS`.
- **`⚠ semuso/install.log já existe — install.log mantido`** (com o nome do arquivo em questão) — o destino já tem um arquivo com esse nome. Renomeie ou apague o de `semuso/` e execute de novo.
- **`git-lib.sh: No such file or directory`** — o `git-lib.sh` precisa estar na mesma pasta do script. A cópia instalada em `/usr/local/bin` não é usada.
- **O arquivo continua aparecendo no `git status`** — ele estava versionado. Faça o commit da remoção (`git commit`) para que o Git deixe de acompanhá-lo.
- **Uso: `mover-para-semuso.sh [-n|--simular]`** — o argumento informado não é reconhecido.