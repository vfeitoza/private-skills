---
name: private-start
description: Início de sessão de trabalho — lê o estado do projeto (git, stack, .session.md, memória persistente) e apresenta um briefing curto. Use quando o usuário invocar `/private-start` ou ao retomar trabalho em um projeto sem contexto carregado.
---

# private-start

Comando de início de sessão. Lê o estado atual do projeto e resume o contexto para trabalho.

## Quando usar
No início de qualquer sessão de trabalho em um projeto.

## O que fazer

1. **Leia o estado do projeto:**
   - Verifique se existe `.session.md` no diretório atual — se sim, leia e apresente o resumo
   - Rode `git status` e `git log --oneline -10` para entender onde o projeto está
   - Leia o `README.md` ou `CLAUDE.md` se existirem
   - Identifique a stack (package.json, Cargo.toml, go.mod, requirements.txt, etc.)

2. **Consulte a memória:**
   - Acesse as memórias do projeto atual se existirem
   - Traga contexto relevante de sessões anteriores

3. **Apresente um briefing curto:**
   ```
   ## Sessão iniciada — [nome do projeto]

   **Stack:** [linguagem/framework detectado]
   **Branch:** [branch atual]
   **Último commit:** [mensagem do último commit]
   **Estado:** [limpo / modificações pendentes / conflitos]

   **Contexto anterior:** [resumo do .session.md se existir, ou "primeira sessão"]

   **Pendências identificadas:** [lista do .session.md ou "nenhuma"]

   Pronto. O que vamos fazer hoje?
   ```

4. **Não faça nada além disso** — não modifique arquivos, não rode testes, não instale dependências.

## Notas
- Se não houver `.session.md`, diga que é a primeira sessão registrada no projeto
- Se o repo estiver sujo (uncommitted changes), mencione os arquivos modificados
- Seja breve — o briefing deve caber em uma tela
