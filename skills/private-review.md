---
name: private-review
description: Revisão de código pré-commit em ordem de prioridade (segurança → corretude → qualidade → consistência). Análise estática que reporta sem modificar — usa `git diff` por padrão ou um escopo específico. Use quando o usuário invocar `/private-review` ou pedir uma revisão antes de commitar/abrir PR.
---

# private-review

Comando para revisão de código antes de commitar. Analisa qualidade, segurança e consistência sem modificar nada.

## Quando usar
Antes de fazer commit ou push, para garantir que o código está pronto.

## Argumento opcional
`/private-review [arquivo ou escopo específico]`

Se nenhum argumento for passado, revisa tudo que está modificado no git (`git diff`).

## O que fazer

### Passo 1 — Coletar o escopo
- Rode `git diff` para ver mudanças não commitadas
- Rode `git diff --staged` para ver mudanças staged
- Se um arquivo específico foi passado, leia-o diretamente
- Se não houver nada no git diff, pergunte o que revisar

### Passo 2 — Analisar o código

Verifique em ordem de prioridade:

**Segurança (crítico):**
- Injeção de SQL, XSS, command injection
- Secrets ou credenciais hardcoded
- Inputs de usuário não validados
- Permissões excessivas

**Corretude (alto):**
- Lógica incorreta ou casos não tratados
- Condições de corrida ou problemas de estado
- Erros que podem ser silenciados incorretamente
- Tipos incorretos ou conversões perigosas

**Qualidade (médio):**
- Código duplicado que poderia ser extraído
- Nomes de variáveis/funções confusos
- Funções muito longas ou com muitas responsabilidades
- Comentários desatualizados ou enganosos

**Consistência (baixo):**
- Padrões do projeto não seguidos
- Formatação inconsistente
- Convenções de nomenclatura quebradas

### Passo 3 — Apresentar o relatório

```
## Revisão de código

**Escopo:** [arquivos revisados]
**Resultado geral:** [Aprovado / Aprovado com ressalvas / Bloqueado]

**Problemas encontrados:**

🔴 Crítico
- `arquivo.ext:linha` — [descrição do problema]

🟡 Importante
- `arquivo.ext:linha` — [descrição do problema]

🔵 Sugestão
- `arquivo.ext:linha` — [descrição do problema]

**Pontos positivos:** (opcional, quando relevante)
- [algo que foi bem feito]
```

Se não houver problemas:
```
## Revisão de código

**Escopo:** [arquivos revisados]
**Resultado:** Aprovado — nenhum problema encontrado.
```

### Passo 4 — Ação
- Não corrija nada automaticamente — apenas reporte
- Se houver problemas críticos, recomende não commitar até resolver
- Pergunte se quer corrigir algum item específico (use `/private-fix` ou `/private-task` para isso)

## Notas
- Esta é uma análise estática — não roda o código
- Foque no que importa: segurança e corretude primeiro, estilo por último
- Não sugira refatorações além do escopo das mudanças revisadas
