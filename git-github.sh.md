# git-github.sh

Envia o projeto para o GitHub e cria o repositório quando ele ainda não existe, perguntando o que for necessário.

**Versão:** 0.3.0  
**Data:** 2026-10-08

**Objetivo da versão:**

- Mostrar um diálogo de andamento enquanto cria o repositório e envia a branch e as tags, para a tela não ficar sem resposta durante o envio
- No terminal, informar o que está sendo feito antes de cada etapa demorada

**Observações de uso:**

- Executar dentro da pasta que contém `.git`, com pelo menos um commit
- Exige chave SSH cadastrada na conta do GitHub
- Criar um repositório novo exige um token clássico com permissão `repo`
- Só cria repositórios na conta pessoal; repositórios de organização são criados pelo site

---

## Visão geral

O `git-github.sh` resolve o trabalho repetitivo de levar uma pasta para o GitHub. Ele atende somente ao GitHub, pois usa a API de criação de repositórios desse serviço. Em cada pasta ele faz o mesmo caminho:

1. Confere se a chave SSH está autenticada no GitHub
2. Descobre ou pergunta o usuário e o nome do repositório
3. Verifica se o repositório existe no GitHub
4. Se não existir, pergunta se deve criá-lo e coleta visibilidade e descrição
5. Configura o `origin` com o endereço SSH
6. Envia a branch atual e as tags

Os diálogos usam o `zenity` quando há ambiente gráfico (ou o Mi.Scripts, que o intercepta) e o terminal quando não há.

---

## Requisitos

- Linux com Bash 4.3 ou superior
- `git`, `ssh` e `curl`
- `xdg-open` (opcional): abre no navegador a página de criação do token. Sem ele, o endereço aparece no diálogo
- Git Tools instalado (`git-lib.sh` em `/usr/local/bin`)
- Conta no GitHub
- Chave SSH cadastrada nessa conta (Passo 1)
- Um token clássico, apenas na primeira vez que criar cada repositório (Passo 4)

---

## Passo 1 — Chave SSH cadastrada no GitHub

A chave SSH autoriza o envio dos arquivos. Ela é única para a máquina e para a conta: cadastrada uma vez, vale para todos os repositórios.

### Verificar se você já tem uma chave

```bash
ls ~/.ssh
```

Se aparecerem arquivos como `id_ed25519` e `id_ed25519.pub` (ou `id_rsa` e `id_rsa.pub`), a chave existe. O arquivo sem `.pub` é a parte privada e nunca deve ser enviado a ninguém. O `.pub` é a parte pública, a que se cadastra no GitHub.

### Criar uma chave (somente se não tiver)

```bash
ssh-keygen -t ed25519 -C "seu-email@exemplo.com"
cat ~/.ssh/id_ed25519.pub
```

Copie todo o texto que o `cat` mostrar.

### Cadastrar no GitHub

No site, clique na sua foto, depois em **Settings**, **SSH and GPG keys** e **New SSH key**. Dê um título, cole a chave pública e salve. A interface pode aparecer em português.

### Testar

```bash
ssh -T git@github.com
```

Resultado esperado:

```
Hi seu-usuario! You've successfully authenticated, but GitHub does not provide shell access.
```

O nome depois de "Hi" deve ser o seu usuário. Se aparecer o nome de um repositório (`Hi seu-usuario/nome-do-repo!`), a chave foi cadastrada como *deploy key*, que vale só para aquele repositório. Cadastre-a na conta e remova a deploy key.

---

## Passo 2 — Instalar o script

O `git-github.sh` já faz parte do git-tools e já consta no `git-tools.conf` (item 13, **Enviar ou atualizar no GitHub (github)**). Basta instalar o git-tools, como usuário comum, sem `sudo`:

```bash
./git-install.sh
source ~/.bashrc
```

O instalador copia o script para `/usr/local/bin`, cria o alias `git-github` e passa a oferecer o comando nos menus do gerenciador de arquivos e do Lazarus.

Se o seu `git-tools.conf` for de uma versão anterior e não tiver essa linha, acrescente-a no mesmo formato das outras, seguindo a numeração que o seu arquivo usa, e rode o instalador de novo:

```
git-github.sh|13 - Enviar ou atualizar no GitHub (github)|Enviar ou atualizar no GitHub|
```

---

## Passo 3 — Preparar a pasta do projeto

A pasta precisa ser um repositório Git com pelo menos um commit. Se ainda não for:

```bash
git-ini.sh
```

Depois faça ao menos um commit, por exemplo com `git-feat.sh`. Sem commit o script avisa e não envia nada.

---

## Passo 4 — Criar o token do GitHub

A chave SSH não consegue criar repositórios. Para isso o script usa a API do GitHub, que exige um token. O token só é pedido quando o repositório ainda não existe.

Quando o token é necessário, o script pergunta se pode abrir a página de criação no navegador. Respondendo **Sim**, a página abre com a **Nota** já preenchida e a caixa **repositório** já marcada, e o diálogo seguinte mostra o passo a passo e o campo para colar o token. Sem ambiente gráfico, ou respondendo **Não**, o endereço aparece no diálogo para você abrir à mão:

```
https://github.com/settings/tokens/new?scopes=repo&description=git-tools%20-%20criar%20repositorios
```

Confira na página se a caixa **repositório** está marcada antes de gerar o token.

Caminho manual: foto do perfil, **Settings**, **Developer settings**, **Personal access tokens**, **Tokens (classic)**, **Generate new token (classic)**.

No formulário:

| Campo | O que fazer |
|-------|-------------|
| **Nota** | Um nome para você reconhecer o token, por exemplo `git-tools - criar repositórios` |
| **Expiração** | Um prazo. Prazo curto é mais seguro; quando vencer, gere outro |
| **Selecione escopos** | Marque **somente** a caixa **repositório** (`repo`). As caixas recuadas abaixo dela são marcadas junto |

Não marque as demais, principalmente `excluir_repo`, `administrador:org`, `fluxo de trabalho` e `escrever:pacotes`.

Clique no botão de gerar o token, no fim da página. O token começa com `ghp_` e **é mostrado uma única vez**: copie na hora.

### Onde o script procura o token

Em ordem:

1. Variável de ambiente `GITHUB_TOKEN` (ou `GH_TOKEN`)
2. O GitHub CLI, se estiver instalado e autenticado (`gh auth login`)
3. Um campo de senha no diálogo, onde você cola o token

O script **não grava** o token em lugar nenhum. Guarde-o em um gerenciador de senhas se for criar outros repositórios.

---

## Passo 5 — Executar

Dentro da pasta do projeto:

```bash
git-github
```

`git-github` é o alias criado pelo instalador; `git-github.sh` faz o mesmo.

Ou pelo menu do gerenciador de arquivos ou do Lazarus, que executam o script na pasta atual.

### O que será perguntado (repositório novo)

| Pergunta | Resposta |
|----------|----------|
| Usuário do GitHub | Já vem sugerido pela chave SSH |
| Nome do repositório | Já vem sugerido pelo `PROJECT_NAME` do `.gitproject`. Use letras, números, ponto, hífen ou sublinhado |
| Repositório não encontrado. Criar agora? | **Sim** |
| Visibilidade | Público ou Privado |
| Descrição | Opcional |
| Token | Cole o token do Passo 4 |

### Resultado esperado

```
To github.com:seu-usuario/seu-projeto.git
 * [new branch]      main -> main
branch 'main' set up to track 'origin/main'.
To github.com:seu-usuario/seu-projeto.git
 * [new tag]         v0.1.0 -> v0.1.0
 ...
```

Em seguida aparece uma mensagem de sucesso com o endereço `https://github.com/seu-usuario/seu-projeto`. Abra-o no navegador e confira os arquivos, os commits e as tags (**Tags**, na lateral).

### Durante o envio

Depois da última pergunta, aparece o diálogo **Enviando a branch ... e as tags para o GitHub. Aguarde...**. Ele não pode ser fechado e some sozinho quando o envio termina. Em seguida surge a mensagem de sucesso, com o botão **OK**. Se o envio falhar, o diálogo de andamento fecha e a mensagem de erro mostra o que o Git respondeu. Projetos grandes, com executáveis e pacotes no histórico, podem levar vários minutos.

### Nas próximas vezes

- **Repositório que já existe:** o script só envia, sem pedir token.
- **`origin` já apontando para o GitHub:** o script não pergunta usuário nem nome do repositório; usa os que estão no `origin`.
- **Outra pasta:** repita o Passo 5. Os Passos 1 a 4 não precisam ser refeitos, exceto o token para cada repositório novo.

---

## Problemas comuns

| Mensagem | Causa e solução |
|----------|-----------------|
| `A chave SSH não está autenticada no GitHub` | A chave não foi cadastrada ou não está sendo oferecida. Refaça o Passo 1. Para investigar, `ssh -vT git@github.com` |
| `Repository not found` (ao rodar `git push` direto) | O repositório não existe ou a chave não tem acesso. O `git-github.sh` trata esse caso criando o repositório |
| `Password authentication is not supported` | O `origin` está em HTTPS e o GitHub não aceita senha. Rode o `git-github.sh`, que troca o `origin` para SSH |
| `remote origin already exists` | Não é erro grave: o `origin` já estava configurado. Veja com `git remote -v` |
| `Token inválido ou expirado` | Gere outro token (Passo 4) e confira se não houve espaço sobrando ao colar |
| `O token pertence a 'X', mas o repositório é de 'Y'` | O token é de outra conta, ou o repositório é de uma organização. Para organização, crie o repositório pelo site |
| `O GitHub recusou a criação` | Geralmente o nome já existe na conta. Se o repositório existir, confira se a chave SSH tem acesso a ele |
| `O repositório ainda não tem nenhum commit` | Faça ao menos um commit antes (Passo 3) |
| `Nenhum repositório Git encontrado` | Execute na pasta que contém `.git`, ou rode `git-ini.sh` |
| Falha ao enviar a branch | Se o nome da branch for `master`, o script já usa o nome real. Veja a mensagem completa no diálogo |

---

## Segurança

- A parte privada da chave SSH (arquivo sem `.pub`) nunca deve ser compartilhada.
- O token dá acesso à sua conta conforme o escopo marcado. Não o envie em conversas nem o grave em arquivos do projeto.
- Se o token vazar, apague-o em **Settings**, **Developer settings**, **Personal access tokens**.
- Marque só o escopo `repo` para limitar o estrago em caso de vazamento.
- O script envia o token ao `curl` pela entrada padrão, sem colocá-lo na linha de comando.

---

## Limitações

- Cria repositórios apenas na conta pessoal do usuário do token.
- Um `origin` que não seja do GitHub recebe apenas o envio, sem criação.
- Não faz `git push --force`; se o remoto tiver commits que a pasta local não tem, o envio é recusado.