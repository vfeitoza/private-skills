# private-test

Comando para verificar cobertura de testes e rodar a suíte existente.

## Quando usar
Após implementar uma feature ou corrigir um bug, para garantir que tudo está funcionando e identificar gaps de cobertura.

## Argumento opcional
`/private-test [arquivo ou módulo específico]`

Se nenhum argumento for passado, analisa o projeto inteiro.

## O que fazer

### Passo 1 — Identificar o framework de testes
Detecte automaticamente pela stack:
- **Node.js:** procure `jest`, `vitest`, `mocha` no `package.json`
- **Python:** procure `pytest`, `unittest`
- **Go:** `go test ./...`
- **Rust:** `cargo test`
- **Ruby:** `rspec`, `minitest`
- Se não encontrar nenhum, informe e pergunte se quer configurar um

### Passo 2 — Rodar os testes
- Execute o comando de teste adequado para a stack
- Capture a saída completa
- Identifique: quantos passaram, quantos falharam, quais falharam

### Passo 3 — Analisar cobertura
Se houver cobertura configurada, rode e apresente. Se não houver:
- Olhe os arquivos modificados recentemente (`git diff --name-only HEAD~1`)
- Verifique se existem testes correspondentes para esses arquivos
- Identifique funções/módulos sem teste

### Passo 4 — Apresentar relatório

```
## Resultado dos testes

**Suíte:** [framework usado]
**Resultado:** [X passaram / Y falharam / Z pulados]

**Falhas:** (se houver)
- `nome_do_teste` — [mensagem de erro resumida]
  Arquivo: `caminho/arquivo.test.ext:linha`

**Gaps de cobertura identificados:**
- `caminho/arquivo.ext` — [função/módulo sem teste]

**Recomendações:**
- [o que vale testar que ainda não está coberto]
```

### Passo 5 — Ação sobre falhas
- Se houver falhas: pergunte se quer corrigir agora ou apenas registrar
- Se houver gaps: pergunte se quer criar os testes faltantes
- Não crie testes automaticamente sem aprovação

## Notas
- Não modifique código de produção neste comando — apenas testes
- Se os testes demorarem muito, rode apenas os relacionados aos arquivos modificados
- Testes que verificam comportamento são mais valiosos que testes que verificam implementação
