# `git-lazarus-integrate.sh` — Integração dos scripts git-tools ao Lazarus

**Versão:** 1.2.0

## Visão geral

O `git-lazarus-integrate.sh` integra os scripts `git-tools` ao ambiente de desenvolvimento Lazarus. Ele permite que as operações Git sejam executadas diretamente pelo menu **Tools** do Lazarus, sem sair da IDE.

O script oferece dois modos de uso:

- **Exportação:** gera um arquivo XML que pode ser importado manualmente no Lazarus.
- **Edição direta:** adiciona as ferramentas diretamente ao arquivo `environmentoptions.xml`, criando um backup antes.

## Pré-requisitos

- Lazarus instalado.
- Os scripts `git-feat.sh`, `git-fix.sh`, `git-breaking.sh`, `git-release.sh` e `version-pas-inc.sh` instalados em `/usr/local/bin/` e com permissão de execução.
- Um arquivo `environmentoptions.xml` existente, ou o caminho para ele informado manualmente.

## Como utilizar

```bash
git-lazarus-integrate.sh [opções]
```

### Opções

| Opção | Descrição |
|---|---|
| `--export` | Exporta as definições para `stdout`, no formato de importação do Lazarus. |
| `--path <arquivo>` | Caminho do `environmentoptions.xml` a ser editado diretamente. |
| `--help` | Exibe a ajuda. |

### Exemplos

Exportar o XML para um arquivo:

```bash
./git-lazarus-integrate.sh --export > git-tools.xml
```

Editar diretamente um arquivo específico:

```bash
./git-lazarus-integrate.sh --path ~/.lazarus/environmentoptions.xml
```

Sem opções, o script procura automaticamente o `environmentoptions.xml` nos locais padrão e o edita.

## Como funciona

1. Lê os argumentos e define o modo de operação.
2. **Modo `--export`:** gera o XML de importação com todas as ferramentas definidas e encerra.
3. **Modo de edição direta:**
   - Localiza o `environmentoptions.xml` nos caminhos padrão (`~/.lazarus/` e `/etc/lazarus/`). Se não encontrar, solicita o caminho ao usuário.
   - Cria um backup (`.bak`) do arquivo, se ainda não existir.
   - Verifica se cada script está instalado e é executável. Se algum estiver ausente, avisa e pergunta se deseja continuar.
   - Adiciona cada ferramenta ao arquivo XML, evitando duplicatas (verifica pelo título).
4. Exibe instruções para reiniciar o Lazarus.

### Ferramentas integradas

| Título no menu | Script | Parâmetro |
|---|---|---|
| Adicionar funcionalidade | `git-feat.sh` | Solicita descrição da funcionalidade |
| Corrigir problema | `git-fix.sh` | Solicita descrição da correção |
| Alteração importante | `git-breaking.sh` | Solicita descrição da breaking change |
| Gerar versão do sistema | `git-release.sh` | — |
| Atualizar informações da versão | `version-pas-inc.sh` | — |

## Comportamento e segurança

- **Backup automático:** o arquivo `environmentoptions.xml` é copiado para `.bak` antes da primeira edição. Se o backup já existir, não é sobrescrito.
- **Idempotência parcial:** ferramentas com o mesmo título já presentes no XML não são adicionadas novamente.
- **Verificação de scripts:** o script avisa se algum dos scripts esperados não existe ou não é executável, mas permite continuar.
- **Edição direta com `sed`:** as ferramentas são inseridas logo após a tag `<Tools>` no XML. Se a estrutura do arquivo for diferente, a inserção pode falhar.
- **Modo exportação:** não altera nenhum arquivo; apenas imprime o XML em `stdout`.

## Arquivos envolvidos

- `environmentoptions.xml` — arquivo de configuração do Lazarus, editado no modo de edição direta.
- `environmentoptions.xml.bak` — backup criado antes da edição.
- `/usr/local/bin/git-*.sh` e `/usr/local/bin/version-pas-inc.sh` — scripts referenciados pelas ferramentas.

## Solução de problemas

- **`⚠ Arquivo environmentoptions.xml não encontrado`** — informe o caminho completo quando solicitado, ou use `--path`.
- **`⚠ Atenção: os seguintes scripts não foram encontrados`** — instale os scripts ausentes em `/usr/local/bin/` e dê permissão de execução, ou prossiga se aceitar a limitação.
- **Ferramentas não aparecem no Lazarus** — reinicie o Lazarus. Se ainda não aparecerem, verifique se o XML foi editado corretamente ou importe o XML gerado com `--export`.
- **Importação manual** — use o XML gerado por `--export` em **Tools → Configure External Tools → Import**.
- **Edição direta falhou** — confirme se o arquivo XML contém a tag `<Tools>`. Estruturas diferentes podem impedir a inserção via `sed`.