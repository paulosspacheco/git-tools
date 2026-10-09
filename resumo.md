# Comandos do Git

Guia rápido e simples de comandos Git, organizados por categoria.

---

## 1. Básicos

### `git init`
Inicia um novo repositório.

### `git clone <url>`
Clona (copia) um repositório existente.

### `git status`
Mostra o status das alterações.

### `git add <arquivo>`
Adiciona alterações para serem commitadas.

### `git add .`
Adiciona todas as alterações do diretório atual.

### `git commit -m "mensagem"`
Salva as alterações com uma mensagem.

### `git commit --amend`
Corrige o último commit (mensagem ou conteúdo).

### `git diff`
Mostra as alterações ainda não adicionadas ao stage.

### `git diff --staged`
Mostra as alterações já adicionadas ao stage.

### `git rm <arquivo>`
Remove um arquivo do repositório e do disco.

### `git mv <origem> <destino>`
Move ou renomeia um arquivo.

### `git show <id-commit>`
Mostra os detalhes de um commit específico.

### `git blame <arquivo>`
Mostra a autoria de cada linha de um arquivo.

---

## 2. Sincronização

### `git pull`
Busca e traz as alterações do repositório remoto e aplica no seu projeto.

### `git push`
Envia suas alterações para o repositório remoto.

### `git fetch`
Busca as alterações do remoto, mas não as aplica.

### `git remote -v`
Mostra os repositórios remotos conectados.

### `git remote add origin <url>`
Adiciona um repositório remoto chamado `origin`.

### `git push -u origin <branch>`
Envia a branch e define o rastreamento remoto.

### `git push origin --tags`
Envia todas as tags locais para o remoto.

---

## 3. Desfazer Alterações

### `git restore <arquivo>`
Desfaz alterações em um arquivo.

### `git reset HEAD <arquivo>`
Remove o arquivo da área de stage (`git add`).

### `git reset --hard HEAD~1`
Descarta o último commit e todas as alterações não commitadas.

### `git revert <id-commit>`
Cria um novo commit que desfaz as alterações de um commit anterior.

### `git reflog`
Mostra o histórico de ações do repositório. Útil para recuperar commits após um reset.

### `git clean -fd`
Remove arquivos e diretórios não rastreados pelo Git.

---

## 4. Branches (Ramificações)

### `git branch`
Lista todas as branches.

### `git switch <nome-da-branch>`
Troca para outra branch.

### `git switch -`
Volta para a branch anterior.

### `git switch -c <nome-da-branch>`
Cria uma nova branch e já muda para ela.

### `git merge <nome-da-branch>`
Mescla as alterações de outra branch na atual.

### `git branch -d <nome-da-branch>`
Remove uma branch já mesclada.

### `git branch -D <nome-da-branch>`
Remove uma branch à força.

### `git branch -m <novo-nome>`
Renomeia a branch atual.

---

## 5. Avançado

### `git log --oneline --graph --all`
Mostra o histórico de commits de forma resumida e visual.

### `git log --oneline -10`
Mostra os 10 commits mais recentes de forma resumida.

### `git stash`
Salva temporariamente suas alterações sem fazer commit.

### `git stash pop`
Restaura as alterações salvas no stash.

### `git rebase <branch>`
Reaplica seus commits sobre outra branch, produzindo um histórico mais limpo.

### `git cherry-pick <id-commit>`
Aplica um commit específico de outra branch.

### `git tag <nome>`
Cria uma tag no commit atual.

### `git tag`
Lista todas as tags.

### `git tag -d <nome>`
Remove uma tag local.

---

## 6. Configuração

### `git config --global user.name "Seu Nome"`
Define o nome usado nos commits.

### `git config --global user.email "email@exemplo.com"`
Define o e-mail usado nos commits.

### `git config --global init.defaultBranch main`
Define `main` como branch padrão para novos repositórios.

### `git config --list`
Lista todas as configurações ativas do Git.

---

## 7. Ajuda

### `git help <comando>`
Mostra a ajuda de um comando específico.

### `git help --all`
Mostra todos os comandos disponíveis.

---

## Dica Rápida

> Use `git status` com frequência. Ele mostra exatamente o que está acontecendo no seu projeto.


