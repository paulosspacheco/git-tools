```markdown
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

### `git commit -m "mensagem"`
Salva as alterações com uma mensagem.

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

---

## 3. Desfazer Alterações

### `git restore <arquivo>`
Desfaz alterações em um arquivo.

### `git reset HEAD <arquivo>`
Remove o arquivo da área de stage (`git add`).

### `git revert <id-commit>`
Cria um novo commit que desfaz as alterações de um commit anterior.

---

## 4. Branches (Ramificações)

### `git branch`
Lista todas as branches.

### `git switch <nome-da-branch>`
Troca para outra branch.

### `git switch -c <nome-da-branch>`
Cria uma nova branch e já muda para ela.

### `git merge <nome-da-branch>`
Mescla as alterações de outra branch na atual.

### `git branch -d <nome-da-branch>`
Remove uma branch já mesclada.

### `git branch -D <nome-da-branch>`
Remove uma branch à força.

---

## 5. Avançado

### `git log --oneline --graph --all`
Mostra o histórico de commits de forma resumida e visual.

### `git stash`
Salva temporariamente suas alterações sem fazer commit.

### `git stash pop`
Restaura as alterações salvas no stash.

### `git rebase <branch>`
Reaplica seus commits sobre outra branch, produzindo um histórico mais limpo.

### `git cherry-pick <id-commit>`
Aplica um commit específico de outra branch.

---

## 6. Ajuda

### `git help <comando>`
Mostra a ajuda de um comando específico.

### `git help --all`
Mostra todos os comandos disponíveis.

---

## Dica Rápida

> Use `git status` com frequência. Ele mostra exatamente o que está acontecendo no seu projeto.
```
