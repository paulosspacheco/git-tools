# `lazarus.git-tools.xml` — Integração das ferramentas Git ao Lazarus

Arquivo de configuração para importação no Lazarus.

## Visão geral

Este arquivo XML define 13 ferramentas externas que integram os scripts `git-tools` ao menu **Tools** do Lazarus. Ele pode ser importado diretamente pela IDE, em **Tools → Configure External Tools → Import**.

Cada ferramenta executa um script instalado em `/usr/local/bin/` e usa o diretório do projeto atual como pasta de trabalho (`$ProjPath()`).

## Pré-requisitos

- Lazarus instalado.
- Os scripts referenciados instalados em `/usr/local/bin/` e com permissão de execução.
- Os scripts `git-feat.sh`, `git-fix.sh`, `git-breaking.sh`, `git-refactor.sh`, `git-docs.sh`, `git-version.sh`, `git-release.sh`, `git-changelog.sh`, `git-changelog-summary.sh`, `git-reset.sh`, `git-undo-reset.sh` e `git-github.sh` disponíveis no sistema.

## Como utilizar

1. No Lazarus, abra **Tools → Configure External Tools**.
2. Clique em **Import**.
3. Selecione o arquivo `lazarus.git-tools.xml`.
4. Confirme a importação.

As ferramentas passam a aparecer no menu **Tools** do Lazarus.

## Ferramentas incluídas

| Nº | Título no menu | Script |
|---|---|---|
| 1 | Inicializar repositório | `git-ini.sh` |
| 2 | Adicionar funcionalidade | `git-feat.sh` |
| 3 | Corrigir problema | `git-fix.sh` |
| 4 | Alteração importante | `git-breaking.sh` |
| 5 | Refatorar código | `git-refactor.sh` |
| 6 | Adicionar documentação | `git-docs.sh` |
| 7 | Calcular próxima versão | `git-version.sh` |
| 8 | Fazer release | `git-release.sh` |
| 9 | Git Changelog | `git-changelog.sh` |
| 10 | Git Changelog Resumo-html | `git-changelog-summary.sh --html` |
| 11 | Git Reset | `git-reset.sh` |
| 12 | Git Undo Reset | `git-undo-reset.sh` |
| 13 | Enviar ou atualizar no GitHub | `git-github.sh` |

A ferramenta 10 é a única que recebe parâmetro: `--html`, para gerar também o `CHANGELOG.html`.

## Estrutura do arquivo

- `<CONFIG Version="3" Count="13">` — elemento raiz, com a versão do formato e o número de ferramentas.
- `<ToolN>` — define cada ferramenta, numerada sequencialmente.
- `<Title Value="..."/>` — nome exibido no menu **Tools**.
- `<Filename Value="..."/>` — caminho absoluto do script a executar.
- `<CmdLineParams Value="..."/>` — parâmetros opcionais passados ao script (presente apenas na ferramenta 10).
- `<WorkingDirectory Value="$ProjPath()"/>` — diretório de trabalho, resolvido pelo Lazarus como a pasta do projeto atual.
- `<Scanners Count="1"><Item1 Value="FPC"/></Scanners>` — configura o scanner de saída como FPC, permitindo que o Lazarus interprete mensagens de erro do compilador.

## Comportamento e segurança

- **Somente configuração:** este arquivo não executa nada por si só. Ele apenas descreve as ferramentas para o Lazarus.
- **Caminhos absolutos:** os scripts devem estar exatamente em `/usr/local/bin/`. Se estiverem em outro local, o XML precisará ser editado.
- **Diretório de trabalho:** cada ferramenta é executada no diretório do projeto Lazarus aberto, não no diretório onde o Lazarus foi iniciado.
- **Importação idempotente:** importar o mesmo XML novamente pode criar entradas duplicadas. Verifique antes de reimportar.

## Solução de problemas

- **Ferramenta não aparece no menu Tools** — confirme que a importação foi concluída e reinicie o Lazarus.
- **`Script não encontrado`** — verifique se o script correspondente existe em `/usr/local/bin/` e é executável.
- **Scripts são executados na pasta errada** — o XML usa `$ProjPath()`. Confirme que um projeto está aberto no Lazarus.
- **Saída do script não é interpretada corretamente** — o scanner está configurado como `FPC`. Se o script não gera mensagens nesse formato, a saída pode não ser reconhecida.
- **Entradas duplicadas** — remova as duplicatas manualmente em **Tools → Configure External Tools**, ou edite o XML antes de reimportar.