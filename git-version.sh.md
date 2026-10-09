# `git-version.sh` — Atualização automática de versão do projeto

**Versão:** 0.1.0
**Data:** 2026-10-08

## Visão geral

O `git-version.sh` calcula e aplica automaticamente a nova versão semântica do projeto, com base nos commits desde a última tag. Ele atualiza o arquivo `.gitproject`, cria a tag correspondente e gera/atualiza arquivos de versão das linguagens presentes na pasta.

O script reconhece projetos Pascal/Lazarus e também atualiza arquivos de versão de outras linguagens, quando existirem.

## Pré-requisitos

- Bash com `sed` do GNU (Linux).
- `git-lib.sh` disponível em `/usr/local/bin/git-lib.sh`, com as funções `load_config`, `ask_confirm` e `notify_info`.
- Repositório Git inicializado na pasta atual (deve existir `.git`).
- Arquivo `.gitproject` com a linha `VERSION=x.y.z`.
- `zenity` — opcional. Se disponível, é usado para caixas de diálogo; caso contrário, o script usa o terminal.

## Como utilizar

```bash
./git-version.sh
```

O script não aceita parâmetros. Deve ser executado na raiz do repositório.

Durante a execução, o script pede confirmação antes de aplicar a nova versão. A resposta pode ser dada via `zenity` (ambiente gráfico) ou pelo terminal.

## Como funciona

1. Garante que as variáveis de display estejam definidas (`DISPLAY`, `DBUS_SESSION_BUS_ADDRESS`, `XDG_RUNTIME_DIR`), para que o `zenity` funcione quando o script é chamado por gerenciadores de arquivos.
2. Carrega `git-lib.sh` e as configurações do `.gitproject`.
3. Verifica se está dentro de um repositório Git e se `VERSION` está definida.
4. Identifica a última tag (`git describe --tags --abbrev=0`).
5. Analisa os commits desde a última tag (ou todos, se não houver tag):
   - `feat!` → incrementa MAJOR.
   - `feat:` → incrementa MINOR.
   - `fix:` → incrementa PATCH.
   - Outros commits não alteram a versão.
6. Se não houver commits relevantes, a versão é mantida e os arquivos de versão são regerados sem bump.
7. Pede confirmação para aplicar a nova versão.
8. Atualiza `.gitproject`, faz commit (`chore: bump version to vX.Y.Z`) e cria a tag `vX.Y.Z`.
9. Gera ou atualiza arquivos de versão conforme as linguagens detectadas.

### Arquivos de versão atualizados

| Arquivo | Linguagem |
|---|---|
| `version-pas.inc` | Pascal/Lazarus (gerado apenas se houver `.lpi`, `.lpr`, `.lpk` ou `.dpr` até 2 níveis) |
| `package.json` | Node.js |
| `pyproject.toml` | Python |
| `Cargo.toml` | Rust |
| `gradle.properties` | Gradle/Java |
| `pubspec.yaml` | Dart/Flutter |

Apenas arquivos que já possuem um campo de versão são alterados. Versões dinâmicas (como `setuptools_scm`) são preservadas.

## Comportamento e segurança

- **Commits automáticos:** o script cria dois commits — o bump de versão em `.gitproject` e, se houver mudanças, o commit dos arquivos de versão.
- **Criação de tag:** a tag `vX.Y.Z` é criada após o commit de bump.
- **Confirmação obrigatória:** a nova versão só é aplicada com confirmação afirmativa.
- **Sem commits relevantes:** se não houver `feat`, `fix` ou `feat!` desde a última tag, a versão é mantida. Nesse caso, os arquivos de versão ainda são regerados.
- **Projetos não reconhecidos:** pastas sem linguagem reconhecida não recebem arquivo de versão.
- **`version-pas.inc` órfão:** um `version-pas.inc` existente em pasta sem projeto Pascal não é apagado. Deve ser removido manualmente (`git rm version-pas.inc`).
- **`sed` do GNU:** o script usa sintaxe específica do `sed` do GNU. Pode não funcionar corretamente em outros ambientes.

## Arquivos envolvidos

- `.gitproject` — atualizado com a nova `VERSION`.
- `version-pas.inc` — gerado em projetos Pascal/Lazarus.
- `package.json`, `pyproject.toml`, `Cargo.toml`, `gradle.properties`, `pubspec.yaml` — atualizados quando presentes e com campo de versão.
- `git-lib.sh` — biblioteca externa, exigida em `/usr/local/bin/`.

## Solução de problemas

- **`❌ Nenhum repositório Git encontrado`** — execute o script dentro de um repositório Git inicializado.
- **`❌ VERSION não definida em .gitproject`** — adicione a linha `VERSION=x.y.z` ao `.gitproject` ou execute `git-config.sh`.
- **`⚠ Nenhum commit relevante`** — não há commits `feat`, `fix` ou `feat!` desde a última tag. A versão é mantida; use as mensagens padrão nos commits.
- **`⚠ Falha no commit do ...`** — verifique se há alterações pendentes ou conflitos no repositório.
- **`version-pas.inc` não é gerado** — confirme se a pasta contém arquivos `.lpi`, `.lpr`, `.lpk` ou `.dpr` até 2 níveis de profundidade.
- **Arquivos de versão não são atualizados** — verifique se o arquivo existe e se contém um campo de versão reconhecido. Versões dinâmicas são preservadas intencionalmente.
- **`zenity` não abre** — verifique se as variáveis `DISPLAY`, `DBUS_SESSION_BUS_ADDRESS` e `XDG_RUNTIME_DIR` estão acessíveis no ambiente. O script tenta defini-las automaticamente.