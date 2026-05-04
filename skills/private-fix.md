# private-fix

Comando para debugging estruturado. Diagnostica o problema antes de mexer no código.

## Quando usar
Ao encontrar um bug, erro inesperado, comportamento incorreto ou falha em teste.

## Argumento opcional
`/private-fix [descrição do problema ou mensagem de erro]`

Se nenhum argumento for passado, pergunte o que está acontecendo.

## O que fazer

### Passo 1 — Coletar informações
Pergunte (ou infira do contexto) o máximo possível:
- Qual é o comportamento esperado?
- Qual é o comportamento atual?
- Quando começou a acontecer? (após qual mudança, se souber)
- Há mensagem de erro? Se sim, qual?

### Passo 2 — Classificar o bug
Determine se é **óbvio** ou **não-óbvio**:

**Óbvio** (vai direto, sem plano):
- Typo em nome de variável/função
- Import faltando
- Erro de sintaxe
- Valor hardcoded errado

**Não-óbvio** (exige mini-plano de investigação):
- Comportamento intermitente
- Erro em runtime sem causa clara
- Regressão após mudança
- Problema de estado/concorrência
- Erro em integração com serviço externo

### Passo 3 — Para bugs não-óbvios, apresente o plano de investigação

```
## Diagnóstico — [descrição do problema]

**Sintoma:** [o que está acontecendo]
**Hipótese principal:** [causa mais provável]
**Hipóteses alternativas:** [outras causas possíveis]

**Plano de investigação:**
1. [onde vou olhar primeiro e por quê]
2. [segundo ponto de investigação]
3. [o que vou verificar para confirmar/descartar cada hipótese]

**Arquivos suspeitos:**
- `caminho/arquivo.ext` — [por que é suspeito]

**O que NÃO vou mudar ainda:** [partes do código que ficam intocadas durante a investigação]

Posso prosseguir com a investigação?
```

### Passo 4 — Aguardar aprovação
- Se aprovado: investigue seguindo o plano
- Se o usuário tiver mais contexto: incorpore e revise o plano

### Passo 5 — Investigar e corrigir
- Leia os arquivos suspeitos
- Confirme ou descarte cada hipótese com evidência do código
- Quando encontrar a causa raiz, informe antes de corrigir:
  ```
  Causa encontrada: [explicação clara]
  Correção: [o que vai mudar]
  Aplicando...
  ```
- Aplique a correção mínima necessária — não aproveite para refatorar

### Passo 6 — Confirmar resolução
Após corrigir, informe:
- O que era o problema
- O que foi alterado
- Como verificar que está resolvido (comando de teste, comportamento esperado)

## Notas
- Prefira a correção mais cirúrgica possível
- Se a correção exigir mudanças maiores do que o esperado, pare e informe o usuário antes de continuar
- Não adicione tratamento de erro para casos que não podem acontecer
