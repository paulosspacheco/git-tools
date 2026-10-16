# Como contribuir com o git-tools

**Versão:** 1.0.0  
**Data:** 2026-10-15

**Objetivo da versão:** primeira versão do guia, dizendo em que idioma o projeto recebe contribuições, como preparar a máquina, quais padrões seguir e como enviar uma mudança.

**Observações:**

- O projeto é mantido em português e **só aceita contribuições em português**
- Ninguém grava direto no `main`: toda mudança chega por pedido (*pull request*) e só entra depois de aprovada pelo mantenedor
- Este guia vale para scripts, documentos e correção de defeitos

---

## Idioma

Tudo o que for escrito no projeto deve estar em **português**: issues, pull requests, mensagens de commit, comentários nos scripts e documentos.

O git-tools nasceu para quem fala português e é mantido nesse idioma. Em inglês já existem milhares de soluções; aqui o objetivo é ter uma ferramenta que qualquer pessoa de língua portuguesa consiga ler, entender e manter.

Issues e pull requests escritos em outro idioma serão fechados com um aviso, sem análise. Se você escreve com ajuda de um tradutor, confira o texto final antes de enviar.

## Maneiras de ajudar

### Avisar de um defeito ou sugerir uma melhoria

Abra um **issue** na aba *Issues* do repositório. Não precisa saber programar. Conte:

1. O que você fez (qual comando ou item do menu).
2. O que esperava que acontecesse.
3. O que aconteceu de fato, copiando a mensagem que apareceu.
4. O resultado do **Ver estado da pasta (state)**, se o problema tiver a ver com commits, tags ou envio.
5. Seu sistema (distribuição, gerenciador de arquivos).

### Enviar uma mudança

Corrigir um script, melhorar uma mensagem, acrescentar um comando ou ajustar um documento. O caminho está em **Como enviar uma mudança**, mais abaixo.

Se a mudança for grande, como um comando novo, abra antes um issue descrevendo a ideia. Assim você descobre se ela cabe no projeto antes de gastar tempo.

## Preparar a máquina

1. Faça um **fork** do repositório (botão *Fork* no site do GitHub).
2. Clone o seu fork:

   git clone git@github.com:paulosspacheco/git-tools.git

   cd git-tools
   ```

3. Ative a validação das mensagens de commit, uma vez por clone:

   ```bash
   git config core.hooksPath .githooks
   ```

4. Crie um ramo para a sua mudança, partindo do `main`:

   ```bash
   git switch -c corrige-mensagem-do-reset
   ```

   Use um nome curto que diga o que o ramo faz.

## Padrões do projeto

### Cabeçalho nos arquivos

Todo arquivo deve começar com um cabeçalho com quatro itens:

- **Data** da versão
- **Versão**
- **Objetivo** da versão
- **Observações** sobre o uso no projeto

Ao mudar um arquivo, atualize a data, a versão e o objetivo. Os scripts em `.sh` e os documentos em `.md` mostram o formato.

### Só código que funciona

Nos scripts vai código funcional. A documentação fica no cabeçalho e no documento do script (`nome-do-script.sh.md`), não espalhada em comentários.

### Mensagens de commit

O projeto usa [Conventional Commits](https://www.conventionalcommits.org/), com a descrição em português. O prefixo é obrigatório, e o hook recusa mensagens fora do padrão:

| Prefixo | Quando usar |
|---------|-------------|
| `feat:` | Funcionalidade nova |
| `fix:` | Correção de defeito |
| `docs:` | Documentação |
| `refactor:` | Reorganização do código, sem mudar o comportamento |
| `style:` | Formatação |
| `test:` | Testes |
| `chore:` | Tarefas de manutenção |
| `feat!:` | Mudança que quebra a compatibilidade |

Se você usa o próprio git-tools, os comandos `git-feat`, `git-fix` e `git-docs` já montam a mensagem no formato certo.

### Não mexa na numeração

Não altere `.gitproject`, `CHANGELOG.md` nem `version-pas.inc`. A versão, a tag e o CHANGELOG são gerados pelo mantenedor quando publica a versão, a partir dos tipos dos commits.

## Rotina de trabalho

Esta é a ordem que o projeto segue. Funciona porque o documento só descreve o que já foi testado:

1. **Altere** os scripts.
2. **Instale** a sua versão para testar: `bash git-install.sh`.
3. **Teste** pelo terminal e, se a mudança aparece no menu, pelo gerenciador de arquivos. Confira o resultado com o **Ver estado da pasta (state)**.
4. **Commite os scripts**, com `feat:` ou `fix:`.
5. **Atualize o documento** do script (`.sh.md`) com o que foi testado.
6. **Commite o documento**, com `docs:`.

Mantenha scripts e documentos em **commits separados**. Os comandos `git-feat`, `git-fix` e `git-docs` adicionam todos os arquivos alterados da pasta, então altere só um tipo de arquivo antes de cada commit.

Antes de enviar, confira a sintaxe de cada script que você mexeu:

```bash
bash -n nome-do-script.sh
```

## Como enviar uma mudança

1. Envie o seu ramo para o seu fork:

   ```bash
   git push -u origin corrige-mensagem-do-reset
   ```

2. No site do GitHub, abra o **pull request** para o `main` do repositório original.
3. Escreva, em português:
   - o que mudou e por quê;
   - como você testou, incluindo o sistema usado;
   - o issue relacionado, se houver.
4. Trate **um assunto por pull request**. Mudanças pequenas e focadas são revisadas mais rápido.

## O que acontece depois

O mantenedor lê o pedido e pode aprovar, pedir ajustes ou recusar, sempre explicando o motivo. Se pedir ajustes, faça novos commits no mesmo ramo: o pedido se atualiza sozinho.

Nem toda mudança entra. O projeto busca ser simples de entender e manter por uma pessoa só, então ideias que aumentam muito o tamanho ou a complexidade podem ser recusadas, mesmo bem feitas. Isso não é uma crítica ao seu trabalho.

## Licença

O projeto é distribuído sob a [licença MIT](LICENSE). Ao enviar uma mudança, você concorda que ela seja distribuída sob a mesma licença.

## Para saber mais

- [readme.md](readme.md): visão geral e uso rápido
- [git-tools-claude.md](git-tools-claude.md): guia completo com todos os comandos
- [git-tools-conf.md](git-tools-conf.md): como o `git-tools.conf` define scripts, menus e aliases