# private-skills

Um conjunto de skills leve para agentes de coding (Claude Code, OpenCode, Cursor, Aider e outros que sigam o padrão `AGENTS.md`), pensado para uso pessoal em projetos com stacks variadas. Sem subagentes, sem diretórios de planejamento, sem overhead — só o fluxo que você precisa.

**Compatibilidade:** mesma fonte de skill, dois harnesses suportados. O instalador escolhe o destino:

| Harness | Global | Por projeto |
|---|---|---|
| Claude Code | `~/.claude/skills/` | `<PROJ>/.claude/skills/` |
| OpenCode (sst/opencode) | `~/.config/opencode/command/` | `<PROJ>/.opencode/command/` |
| **Ambos (`--all`)** | ambos os caminhos acima | ambos os caminhos acima |

📖 **Guias detalhados de uso:**
- [`docs/USAGE-CLAUDE.md`](docs/USAGE-CLAUDE.md) — exemplos completos no Claude Code
- [`docs/USAGE-OPENCODE.md`](docs/USAGE-OPENCODE.md) — exemplos completos no OpenCode

## Comandos disponíveis

| Comando | Quando usar |
|---|---|
| `/private-start` | Início de sessão — resume contexto do projeto (`.session.md` + `.agent-memory.md`) |
| `/private-create` | Cria ou atualiza `AGENTS.md` (com symlink `CLAUDE.md → AGENTS.md`) — lê código existente ou levanta requisitos do zero |
| `/private-task` | Nova feature ou mudança — com mini-plano para tarefas não-triviais |
| `/private-fix` | Bug ou comportamento inesperado — diagnóstico antes de mexer no código |
| `/private-test` | Após implementar — roda testes e identifica gaps de cobertura |
| `/private-doc` | Documentar algo — com mini-plano para documentação estrutural |
| `/private-review` | Antes de commitar — checa segurança, corretude e consistência |
| `/private-end` | Fim de sessão — salva estado em `.session.md` e fatos duradouros em `.agent-memory.md` |

---

## Instalação

> Padrão: **Claude Code**. Para instalar no **OpenCode**, adicione `--opencode` em qualquer comando abaixo.

### Opção 1 — Global (todos os projetos)

```bash
git clone https://github.com/vfeitoza/private-skills.git
cd private-skills

./install.sh              # Claude Code → ~/.claude/skills/
./install.sh --opencode   # OpenCode    → ~/.config/opencode/command/
./install.sh --all        # ambos os destinos acima, em uma chamada
```

Reinicie o agente após instalar.

---

### Opção 2 — Projeto específico

Instala em `<PROJETO>/.claude/skills/` (Claude Code) ou `<PROJETO>/.opencode/command/` (OpenCode). Os comandos ficam disponíveis apenas dentro desse projeto.

**Modo interativo** (pergunta se você quer o diretório atual ou outro):

```bash
cd /caminho/para/private-skills
./install.sh --project              # Claude Code, interativo
./install.sh --opencode --project   # OpenCode, interativo
```

Você verá:

```
Onde instalar os skills?
  1) Diretório atual: /caminho/atual
  2) Informar outro path

Escolha [1/2] (padrão: 1):
```

**Modo direto** (informa o path como argumento, sem prompt):

```bash
./install.sh --project ~/Projetos/meu-app
./install.sh --project /opt/codigo/api
./install.sh --project .                          # diretório atual

./install.sh --opencode --project ~/Projetos/api  # OpenCode
./install.sh --all --project ~/Projetos/api       # ambos os harnesses no projeto
```

Aceita `~`, paths relativos e absolutos. Se o diretório não existir, o script pergunta antes de criar.

Reinicie o agente após instalar.

---

### Instalação manual

Se preferir instalar sem o script, copie os arquivos da pasta `skills/` para o destino correspondente ao harness:

**Claude Code (global):**
```bash
mkdir -p ~/.claude/skills
cp skills/*.md ~/.claude/skills/
```

**OpenCode (global):**
```bash
mkdir -p ~/.config/opencode/command
cp skills/*.md ~/.config/opencode/command/
```

**Por projeto:** troque o destino para `<PROJ>/.claude/skills/` ou `<PROJ>/.opencode/command/`.

Reinicie o agente após copiar.

---

## Atualização

```bash
cd /caminho/para/private-skills
git pull
./install.sh                                       # Claude Code, global
./install.sh --opencode                            # OpenCode, global
./install.sh --all                                 # ambos, global
./install.sh --project ~/meu-projeto               # Claude Code, projeto
./install.sh --opencode --project ~/meu-projeto    # OpenCode, projeto
./install.sh --all --project ~/meu-projeto         # ambos, projeto
```

O script detecta automaticamente o que mudou e atualiza apenas os arquivos necessários.

---

## Desinstalação

```bash
./install.sh --uninstall                                       # Claude global
./install.sh --uninstall --opencode                            # OpenCode global
./install.sh --uninstall --all                                 # ambos global
./install.sh --uninstall --project ~/meu-projeto               # Claude, projeto
./install.sh --uninstall --opencode --project ~/meu-projeto    # OpenCode, projeto
./install.sh --uninstall --all --project ~/meu-projeto         # ambos, projeto
./install.sh --uninstall --project                             # interativo
```

---

## Como funciona

Cada skill é um arquivo `.md` que instrui o agente sobre como se comportar quando o comando é invocado. Não há subagentes, não há arquivos intermediários de planejamento — o agente executa diretamente na conversa.

**Mini-plano:** os comandos `/private-task`, `/private-fix` e `/private-doc` apresentam um plano inline antes de executar, para tarefas não-triviais. O plano fica na conversa — não cria arquivos em disco. Você aprova antes de qualquer mudança ser feita.

**Estado de sessão (efêmero — `.session.md`):** o `/private-end` salva um arquivo `.session.md` na raiz do projeto com o resumo do que foi feito, pendências e decisões. O `/private-start` lê esse arquivo para retomar o contexto. Sobrescrito a cada sessão. **Gitignorado por padrão.**

**Memória portátil (duradoura — `.agent-memory.md`):** fatos que sobrevivem entre sessões — o que o projeto faz, decisões arquiteturais, preferências do usuário, referências externas. Incremental (não sobrescrito). Funciona em **qualquer harness**. **Gitignorado por padrão.**

**Memória nativa do Claude Code (opcional):** quando rodando em Claude Code, `/private-end` também espelha fatos relevantes em `~/.claude/projects/<projeto>/memory/`. Em OpenCode/Cursor/Aider, o `.agent-memory.md` é a fonte canônica.

---

## Relação com skills nativos

Cada harness já oferece skills próprios — `/init`, `/review`, `/security-review` no Claude Code; comandos similares no OpenCode. Os `/private-*` **coexistem** sem conflito:

| Caso | Use o nativo | Use o privado |
|---|---|---|
| Gerar `AGENTS.md`/`CLAUDE.md` rapidamente em projeto novo | `/init` (Claude Code) | `/private-create` (PT-BR, fluxo de estados A/B/C/D) |
| Revisar PR/branch antes de mergear | `/review` (Claude Code) | — |
| Auditoria de segurança em mudanças pendentes | `/security-review` (Claude Code) | — |
| Revisão local pré-commit (segurança + corretude + qualidade + consistência) | — | `/private-review` |
| Fluxo coeso de início/fim de sessão com `.session.md` e `.agent-memory.md` | — | `/private-start` + `/private-end` |
| Mini-plano em PT-BR antes de implementar feature/fix | — | `/private-task` + `/private-fix` |

---

## Estrutura do repositório

```
private-skills/
├── skills/                  # fonte única (8 skills .md)
│   ├── private-start.md
│   ├── private-create.md
│   ├── private-task.md
│   ├── private-fix.md
│   ├── private-test.md
│   ├── private-doc.md
│   ├── private-review.md
│   └── private-end.md
├── docs/
│   ├── USAGE-CLAUDE.md      # guia detalhado para Claude Code
│   └── USAGE-OPENCODE.md    # guia detalhado para OpenCode
├── install.sh               # instalador (Claude Code + OpenCode)
├── AGENTS.md                # spec do meta-projeto (lida pelos agentes)
├── CLAUDE.md → AGENTS.md    # symlink (retrocompatibilidade)
├── CHANGELOG.md
├── LICENSE
└── README.md
```

---

## Customização

Os skills são arquivos Markdown simples com frontmatter YAML (`name`, `description`) seguido do corpo. Para ajustar o comportamento de qualquer comando, edite o arquivo correspondente no destino instalado:

- Claude Code global: `~/.claude/skills/<nome>.md`
- Claude Code projeto: `<PROJ>/.claude/skills/<nome>.md`
- OpenCode global: `~/.config/opencode/command/<nome>.md`
- OpenCode projeto: `<PROJ>/.opencode/command/<nome>.md`

> **Atenção:** o frontmatter (`---\nname: ...\ndescription: ...\n---`) é obrigatório no Claude Code. Sem ele o harness não registra o arquivo como skill invocável. O OpenCode aceita arquivos com ou sem frontmatter — `description` aparece no menu `/`.

---

## Contribuindo

Para alterações no próprio repositório:

1. Edite o(s) skill(s) em `skills/`.
2. Bump de versão em `install.sh` (constante `VERSION`).
3. Adicione entrada em `CHANGELOG.md` seguindo Keep a Changelog.
4. Rode `bash -n install.sh && ./install.sh --help` antes de commitar.
5. Se acrescentar/remover comandos, atualize também os guias em `docs/USAGE-*.md`.

---

## Licença

[MIT](LICENSE) — uso pessoal, comercial, modificação e redistribuição permitidos. Consulte o arquivo `LICENSE` para detalhes.
