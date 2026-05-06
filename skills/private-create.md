---
name: private-create
description: Cria ou atualiza o `CLAUDE.md` do projeto. Detecta automaticamente se o projeto está vazio, sem CLAUDE.md ou com CLAUDE.md existente — e segue o fluxo correto: levantamento de requisitos via perguntas, inferência a partir do código, ou atualização cirúrgica. Use quando o usuário invocar `/private-create` ou pedir para criar/atualizar/regenerar o CLAUDE.md.
---

# private-create

Comando para criar ou atualizar o CLAUDE.md do projeto. Analisa o código existente ou levanta requisitos do zero via perguntas.

## Quando usar
- Ao iniciar um projeto novo (projeto vazio ou sem CLAUDE.md)
- Ao incorporar um projeto existente que ainda não tem CLAUDE.md
- Ao atualizar um CLAUDE.md desatualizado após mudanças significativas

## O que fazer

### Passo 1 — Verificar o estado do projeto

Rode `find . -not -path './.git/*' -not -path './node_modules/*' -not -path './.venv/*' | head -60` para entender o que existe.

Classifique o projeto em um de três estados:

**A) Projeto vazio** — nenhum arquivo além de `.git` (ou sem git)
**B) Projeto existente sem CLAUDE.md** — tem código mas não tem CLAUDE.md
**C) Projeto existente com CLAUDE.md** — tem código e já tem CLAUDE.md

---

### Estado A — Projeto vazio

Faça as perguntas abaixo em sequência, uma de cada vez, esperando a resposta antes de continuar. Não faça todas de uma vez.

**Bloco 1 — Identidade do projeto**
1. Qual é o nome do projeto?
2. Em uma frase, o que ele faz?
3. Qual problema ele resolve e para quem?

**Bloco 2 — Stack e tecnologia**
4. Qual linguagem principal? (e versão, se souber)
5. Vai usar algum framework? (ex: Next.js, FastAPI, Gin, Rails — ou nenhum)
6. Banco de dados? (PostgreSQL, SQLite, MongoDB, nenhum, ainda não sei)
7. Vai ter interface visual? (web, mobile, CLI, API apenas, outro)
8. O projeto vai expor endpoints HTTP? Se sim, já tem preferência de como documentar? (vou usar OpenAPI por padrão)

**Bloco 3 — Estrutura e padrões**
9. Como quer organizar o código? (monolito, módulos separados, microserviços, ainda não sei)
10. Tem preferência de estrutura de pastas? (ou posso sugerir uma padrão para a stack)
11. Vai ter testes? Qual abordagem? (unitários, integração, e2e, TDD, ou depois vejo)

**Bloco 4 — Contexto de desenvolvimento**
12. É um projeto solo ou vai ter colaboradores?
13. Tem algum prazo ou milestone importante?
14. Tem alguma restrição técnica que eu deva saber? (ex: não pode usar X, precisa rodar offline, etc.)
15. Tem alguma convenção de código que quer seguir? (ex: Airbnb style, PEP8, ou padrão da linguagem)

**Bloco 5 — Funcionalidades iniciais**
16. Quais são as 3-5 funcionalidades principais que o projeto precisa ter?
17. O que está fora do escopo desta versão inicial?

Após coletar todas as respostas, vá para o Passo 3.

---

### Estado B — Projeto existente sem CLAUDE.md

Pergunte:
> "Encontrei arquivos no projeto. Posso ler o código para gerar o CLAUDE.md automaticamente, ou prefere responder perguntas manualmente? (ler código / responder perguntas)"

**Se escolher "ler código":**
- Leia os arquivos principais: entry points, configurações (package.json, pyproject.toml, go.mod, Cargo.toml, etc.), estrutura de pastas, README se existir
- Infira: stack, estrutura, padrões usados, dependências principais
- Apresente um resumo do que entendeu e pergunte se está correto antes de gerar o CLAUDE.md
- Complemente com perguntas apenas para o que não conseguiu inferir

**Se escolher "responder perguntas":**
- Siga o mesmo roteiro do Estado A, mas pule perguntas que já são óbvias pelo código

Após coletar as informações, vá para o Passo 3.

---

### Estado C — Projeto existente com CLAUDE.md

Leia o CLAUDE.md atual e apresente:
```
CLAUDE.md encontrado. Última atualização: [data se disponível]

Seções atuais:
- [lista das seções existentes]

O que deseja fazer?
1. Atualizar seções específicas
2. Regenerar completamente (lendo o código atual)
3. Adicionar informações que estão faltando
```

Aguarde a escolha e proceda conforme:
- **Atualizar seções:** pergunte quais seções e o que mudou, depois edite cirurgicamente
- **Regenerar:** leia o código atual, compare com o CLAUDE.md existente, gere uma versão nova preservando decisões manuais que não são deriváveis do código
- **Adicionar:** pergunte o que está faltando e incorpore

---

### Passo 3 — Gerar o CLAUDE.md

Com todas as informações coletadas, gere o arquivo `CLAUDE.md` na raiz do projeto com esta estrutura:

```markdown
# [Nome do Projeto]

[Descrição em uma frase — o que faz e para quem]

## Stack

- **Linguagem:** [linguagem + versão]
- **Framework:** [framework ou "nenhum"]
- **Banco de dados:** [banco ou "nenhum"]
- **Interface:** [web / CLI / API / mobile]

## Estrutura do projeto

[Descrição da organização de pastas — gerada ou acordada]

## Comandos essenciais

```bash
# Instalar dependências
[comando]

# Rodar em desenvolvimento
[comando]

# Rodar testes
[comando]

# Build
[comando]
```

## Convenções

- [convenção de código acordada]
- [padrão de nomenclatura]
- [outras convenções relevantes]
- Documentação de endpoints HTTP é obrigatória via OpenAPI (se o projeto expõe endpoints)

## Documentação de API

> Inclua esta seção apenas se o projeto expõe endpoints HTTP.

- **Especificação OpenAPI:** `openapi.yaml` (OpenAPI 3.x)
- Todo endpoint deve estar documentado: path, método, parâmetros, request body, responses e autenticação
- Manter o arquivo atualizado a cada novo endpoint ou mudança de contrato é obrigatório

## Decisões de arquitetura

- [decisão 1 — o que foi escolhido e por quê]
- [decisão 2]

## Fora do escopo (v1)

- [o que não será feito nesta versão]

## Contexto importante

[Qualquer informação que o Claude precisa saber para trabalhar bem neste projeto — restrições, integrações externas, comportamentos não-óbvios]
```

Adapte as seções conforme o projeto — remova seções que não se aplicam, adicione seções específicas se necessário.

### Passo 4 — Confirmar antes de escrever

Apresente o CLAUDE.md gerado na conversa e pergunte:
> "Posso salvar este CLAUDE.md no projeto?"

Só escreva o arquivo após confirmação.

### Passo 5 — Confirmar criação

Após salvar:
```
CLAUDE.md criado em [caminho].

Próximos passos sugeridos:
- /private-task — para começar a primeira implementação
- /private-start — para iniciar a sessão com o novo contexto
```

## Notas
- Nunca sobrescreva um CLAUDE.md existente sem mostrar o novo conteúdo primeiro
- Para projetos existentes, prefira inferir do código a fazer perguntas desnecessárias
- O CLAUDE.md é para o Claude, não para humanos — seja técnico e direto, sem floreios
- Se o projeto tiver um README.md, o CLAUDE.md não precisa repetir o que já está lá — referencie
