# private-task

Comando para iniciar uma nova implementação. Clarifica escopo, apresenta mini-plano e pede aprovação antes de executar.

## Quando usar
Ao iniciar qualquer nova feature, mudança de comportamento, refatoração ou adição de funcionalidade.

## Argumento opcional
`/private-task [descrição breve da tarefa]`

Se nenhum argumento for passado, pergunte o que o usuário quer implementar.

## O que fazer

### Passo 1 — Entender o contexto
- Leia os arquivos relevantes para a tarefa descrita
- Verifique o `.session.md` se existir
- Identifique padrões existentes no código que devem ser seguidos

### Passo 2 — Classificar a tarefa
Determine se a tarefa é **trivial** ou **não-trivial**:

**Trivial** (vai direto, sem plano):
- Correção de texto/typo
- Mudança de valor de constante
- Adição de um import
- Renomeação simples e localizada

**Não-trivial** (exige mini-plano):
- Qualquer coisa que toque mais de 2 arquivos
- Nova funcionalidade
- Mudança de interface/API
- Refatoração
- Integração com serviço externo

### Passo 3 — Para tarefas não-triviais, apresente o mini-plano

```
## Plano — [nome da tarefa]

**Objetivo:** [o que será entregue em uma frase]

**Arquivos afetados:**
- `caminho/arquivo.ext` — [o que muda]
- `caminho/outro.ext` — [o que muda]

**Ordem de execução:**
1. [primeiro passo]
2. [segundo passo]
3. [terceiro passo]

**Riscos / decisões:**
- [risco ou decisão relevante, se houver]

**Fora do escopo:**
- [o que NÃO será feito nesta tarefa]

Posso prosseguir?
```

### Passo 4 — Aguardar aprovação
- Se o usuário aprovar (sim / ok / pode ir / etc): execute o plano
- Se o usuário pedir ajustes: revise o plano e apresente novamente
- Se a tarefa for trivial: execute diretamente sem apresentar plano

### Passo 5 — Executar
- Implemente seguindo exatamente o plano aprovado
- Não adicione features extras além do escopo
- **Se a tarefa criar ou modificar endpoints HTTP:** a documentação OpenAPI é obrigatória — atualize `openapi.yaml` (ou crie se não existir) junto com o código. Endpoint sem doc OpenAPI = tarefa incompleta
- Ao terminar, informe o que foi feito em 2-3 linhas

## Notas
- O plano fica na conversa, não cria arquivos em disco
- Não rode testes automaticamente — isso é responsabilidade do `/private-test`
- Se durante a execução descobrir algo que muda o escopo, pare e informe o usuário
