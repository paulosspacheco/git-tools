# Prompt — Documentação Padronizada de Scripts e Ferramentas para GitHub

## Objetivo

Crie uma documentação em Markdown para o GitHub que oriente um novo usuário a entender e utilizar o script, programa ou ferramenta fornecida.

A documentação deve ser simples, objetiva, didática e padronizada. Seu propósito é ensinar o usuário a utilizar a ferramenta, e não explicar detalhadamente sua implementação interna.

## Critérios obrigatórios

### 1. Público-alvo

Considere um usuário que conhece o básico de informática, mas pode não conhecer o funcionamento interno da ferramenta documentada.

Explique os conceitos necessários para utilizar o recurso, sem presumir conhecimentos técnicos que não sejam essenciais.

### 2. Nível de detalhamento

- Descreva o que a ferramenta faz, para que serve e como utilizá-la.
- Explique as etapas principais de funcionamento, sem reproduzir linha por linha o código-fonte.
- Inclua exemplos práticos de utilização quando forem úteis.
- Apresente somente as informações necessárias para o usuário executar a ferramenta com segurança e compreender seus resultados.
- Evite explicações redundantes, longas introduções, tabelas desnecessárias e repetições do mesmo conteúdo.
- Não transforme a documentação de uso em uma auditoria ou revisão de código.

### 3. Estrutura padronizada

Utilize as seções abaixo, selecionando somente aquelas aplicáveis à ferramenta.

1. **Título:** nome da ferramenta e, quando disponível, sua versão.
2. **Visão geral:** descrição breve do propósito e dos benefícios.
3. **Pré-requisitos:** programas, arquivos auxiliares ou configurações necessárias.
4. **Como utilizar:** sintaxe de execução e exemplos práticos.
5. **Como funciona:** resumo das principais etapas de execução, na ordem em que ocorrem.
6. **Comportamento e segurança:** informações relevantes sobre arquivos preservados, alterações realizadas, confirmações solicitadas e efeitos de execuções repetidas.
7. **Arquivos envolvidos:** arquivos criados ou modificados, quando aplicável.
8. **Solução de problemas:** erros comuns e orientações objetivas para resolvê-los, quando necessário.

Não crie seções vazias. Não inclua todas as seções automaticamente se a ferramenta não precisar delas.

### 4. Fidelidade ao código-fonte

A documentação deve refletir o comportamento real da implementação fornecida.

- Não invente funcionalidades, parâmetros, dependências ou garantias.
- Não afirme que uma operação é segura, automática ou idempotente sem respaldo no código.
- Diferencie o comportamento efetivamente implementado das recomendações opcionais.
- Quando houver uma limitação importante que possa afetar a utilização, explique-a brevemente.
- Não liste possíveis melhorias de programação, detalhes de implementação ou casos extremos que não sejam relevantes para o usuário comum.

### 5. Preservação de data, versão e metadados

Examine o cabeçalho do código-fonte antes de elaborar a documentação.

- Se houver uma **versão**, transcreva-a exatamente como aparece no cabeçalho.
- Se houver uma **data**, transcreva-a exatamente como aparece no cabeçalho, preservando o formato original.
- Preserve também outros metadados relevantes presentes no cabeçalho, como nome do programa, autor, licença ou descrição, quando aplicável.
- Apresente a versão e a data preferencialmente junto ao título ou na seção de identificação da ferramenta.
- Não invente, atualize, corrija ou deduza uma data ou versão que não esteja explicitamente informada.
- Se uma dessas informações não estiver disponível, simplesmente omita-a. Não confunda a data atual com a data de criação ou atualização do programa.

### 6. Formato Markdown

- Utilize Markdown compatível com GitHub.
- Use `#` para o título principal e `##` para as seções.
- Use `###` somente quando uma subseção for realmente necessária.
- Utilize listas para procedimentos e tabelas apenas quando facilitarem a consulta.
- Formate comandos, nomes de arquivos, parâmetros e caminhos como código inline.
- Utilize blocos de código com a linguagem apropriada para exemplos executáveis.
- Inclua um sumário somente quando o tamanho do documento justificar sua presença.

### 7. Linguagem e estilo

- Escreva em português brasileiro, salvo se outro idioma for solicitado.
- Prefira frases curtas, vocabulário acessível e instruções diretas.
- Explique termos técnicos apenas quando necessário para o entendimento.
- Evite linguagem promocional, formalidade excessiva e explicações acadêmicas.
- Não repita no texto aquilo que já está claramente demonstrado em um exemplo.
- Priorize a facilidade de leitura e consulta por usuários iniciantes.

### 8. Controle de extensão

A documentação deve ter o menor tamanho possível sem omitir informações necessárias para a utilização correta da ferramenta.

Como referência, procure produzir entre 300 e 700 palavras para ferramentas simples. Ultrapasse esse intervalo somente quando a complexidade real da utilização justificar.

Não aumente o documento apenas para preencher todas as seções sugeridas.

## Revisão antes da entrega

Antes de apresentar o documento, verifique internamente:

1. Um novo usuário consegue entender para que serve a ferramenta?
2. Consegue identificar os pré-requisitos e executar os exemplos?
3. Entende os principais efeitos da execução?
4. As informações correspondem ao código-fonte fornecido?
5. A data, a versão e os metadados do cabeçalho foram preservados corretamente, quando existentes?
6. Existem repetições, explicações excessivas ou detalhes internos dispensáveis?
7. O documento está pronto para ser salvo em um arquivo `.md` no GitHub?

Se houver conteúdo que não ajude o usuário a entender, executar ou utilizar a ferramenta corretamente, remova-o.

## Entrada

Analise o código-fonte, as informações de versão e os arquivos auxiliares fornecidos a seguir.

## Saída esperada

Entregue somente a documentação final em Markdown, pronta para ser adicionada ao repositório GitHub. Não inclua uma análise do processo de documentação, comentários sobre suas escolhas ou sugestões adicionais fora do documento, salvo se houver alguma informação essencial ausente que impeça uma documentação confiável.

### Extensão e nível de detalhe

- Determine a extensão da documentação com base no conteúdo, na complexidade e nas funcionalidades reais da ferramenta.
- Não estabeleça limites fixos de palavras, linhas ou seções.
- Seja conciso, mas não omita informações necessárias para que um usuário iniciante compreenda e utilize a ferramenta corretamente.
- Explique apenas o que for relevante para o usuário. Evite detalhes técnicos internos que não contribuam para a utilização da ferramenta.
- Elimine repetições, reúna informações relacionadas e evite criar seções que apenas repitam conteúdo já explicado.
- Não acrescente conteúdo apenas para tornar a documentação mais completa ou extensa.
- Priorize a clareza, a utilidade prática e a fidelidade ao comportamento efetivamente implementado.