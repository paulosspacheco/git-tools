# `git-release.sh` — Geração de release do projeto

**Versão:** 1.0.2

## Visão geral

O `git-release.sh` executa o fluxo completo de release do projeto. Ele delega o cálculo e a aplicação da nova versão semântica ao script `git-version.sh`, que também atualiza os arquivos de versão das linguagens encontradas na pasta (o `version-pas.inc` só é gerado em projetos Pascal/Lazarus). Ao final, exibe uma mensagem de sucesso com a versão criada.

## Pré-requisitos

- Bash.
- `git-lib.sh` no mesmo diretório do script, com as funções `load_config` e `notify_info`.
- `git-version.sh` no mesmo diretório do script, com permissão de execução (ele é chamado diretamente, não por `bash`).
- O git-tools instalado: o `git-version.sh` carrega `/usr/local/bin/git-lib.sh`, mesmo quando o `git-release.sh` é executado de outra pasta.
- Arquivo `.gitproject` com a variável `VERSION` definida após a execução do `git-version.sh`.
- `zenity` — opcional. Se ausente, o script pausa no terminal aguardando o usuário pressionar Enter.

## Como utilizar

```bash
./git-release.sh
```

O script não aceita parâmetros. Deve ser executado na raiz do repositório.

### Exemplo

```bash
./git-release.sh
```

Resultado esperado:

```text
🚀 Gerando release
...
✅ Release criado com sucesso!

Versão: v1.2.3

O projeto foi atualizado e a tag v1.2.3 foi criada.
```

## Como funciona

1. Carrega as funções auxiliares de `git-lib.sh`.
2. Executa `git-version.sh`, que calcula a nova versão, pede confirmação, atualiza o `.gitproject`, cria o commit de versão e a tag, e atualiza os arquivos de versão da linguagem do projeto.
3. Se `git-version.sh` falhar, o script encerra com código `1`.
4. Carrega as configurações com `load_config`.
5. Verifica se a variável `VERSION` está definida. Se não estiver, encerra com erro.
6. Exibe a mensagem de sucesso com a versão criada.
7. Se não houver ambiente gráfico (`DISPLAY` e `WAYLAND_DISPLAY` ausentes) ou o `zenity` não estiver disponível, pausa aguardando Enter.

## Comportamento e segurança

- **Delegação:** toda a lógica de versionamento, criação de tag e geração dos arquivos de versão (como o `version-pas.inc` em projetos Pascal) é responsabilidade do `git-version.sh`.
- **Dependência do `.gitproject`:** se o arquivo não existir ou não contiver `VERSION` após a execução do `git-version.sh`, o script encerra com erro.
- **Pausa condicional:** em ambientes gráficos com `zenity`, a pausa final não é exibida. A mensagem é apresentada pelo `notify_info`.
- **Encadeamento de erros:** falhas no `git-version.sh` interrompem a execução do release.
- **Mensagem de sucesso sem nova versão:** se o `git-version.sh` terminar sem erro mas sem criar versão (você cancelou a confirmação, ou não há commits `feat`/`fix` desde a última tag), o `git-release.sh` continua e mostra a mensagem de sucesso com a versão que já estava no `.gitproject`. Confira com `git tag` se a tag foi realmente criada.

## Arquivos envolvidos

- `git-lib.sh` — biblioteca de funções, exigida no mesmo diretório.
- `git-version.sh` — responsável pelo cálculo da versão, criação da tag e geração dos arquivos de versão.
- `version-pas.inc` e outros arquivos de versão (`package.json`, `pyproject.toml`, `Cargo.toml`, `gradle.properties`, `pubspec.yaml`) — atualizados pelo `git-version.sh` conforme a linguagem encontrada na pasta.
- `/usr/local/bin/git-lib.sh` — biblioteca exigida pelo `git-version.sh`.
- `.gitproject` — arquivo de configuração lido por `load_config` para obter `VERSION`.

## Solução de problemas

- **`❌ VERSION não definida em .gitproject`** — verifique se o `git-version.sh` foi executado com sucesso e se o `.gitproject` contém a linha `VERSION=...`.
- **Falha no `git-version.sh`** — consulte a documentação desse script. O release não prossegue sem ele.
- **Erro ao carregar `git-lib.sh`** — verifique se o arquivo está no mesmo diretório do `git-release.sh`.
- **Script pausa aguardando Enter mesmo em ambiente gráfico** — o `zenity` pode não estar instalado. Instale-o ou pressione Enter para continuar.
- **Tag não criada** — a criação da tag é responsabilidade do `git-version.sh`. Verifique se ele foi executado corretamente.
- **Mensagem de sucesso, mas a versão não mudou** — veja o item sobre mensagem de sucesso sem nova versão em *Comportamento e segurança*. Faça ao menos um commit `feat:` ou `fix:` e rode de novo.
- **`Permission denied` ao chamar o `git-version.sh`** — dê permissão de execução: `chmod +x git-version.sh`.
- **`/usr/local/bin/git-lib.sh: No such file or directory`** — o erro vem do `git-version.sh`. Instale o git-tools com `bash git-install.sh`.