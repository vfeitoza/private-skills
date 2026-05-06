# private-skills

Um conjunto de skills leve para o Claude Code, pensado para uso pessoal em projetos com stacks variadas. Sem subagentes, sem diretórios de planejamento, sem overhead — só o fluxo que você precisa.

## Comandos disponíveis

| Comando | Quando usar |
|---|---|
| `/private-start` | Início de sessão — resume contexto do projeto |
| `/private-create` | Cria ou atualiza o CLAUDE.md — lê o código existente ou levanta requisitos do zero |
| `/private-task` | Nova feature ou mudança — com mini-plano para tarefas não-triviais |
| `/private-fix` | Bug ou comportamento inesperado — diagnóstico antes de mexer no código |
| `/private-test` | Após implementar — roda testes e identifica gaps de cobertura |
| `/private-doc` | Documentar algo — com mini-plano para documentação estrutural |
| `/private-review` | Antes de commitar — checa segurança, corretude e consistência |
| `/private-end` | Fim de sessão — salva contexto em memória e no `.session.md` do projeto |

---

## Instalação

### Opção 1 — Global (todos os projetos)

Instala os skills em `~/.claude/skills/`, disponibilizando os comandos em qualquer projeto.

```bash
git clone https://github.com/vfeitoza/private-skills.git
cd private-skills
./install.sh
```

Reinicie o Claude Code após instalar.

---

### Opção 2 — Projeto único

Instala os skills em `.claude/skills/` dentro do projeto atual. Os comandos ficam disponíveis apenas neste projeto.

```bash
# A partir do diretório raiz do seu projeto:
git clone https://github.com/vfeitoza/private-skills.git /tmp/private-skills
cd /tmp/private-skills
./install.sh --project
```

Ou, se já tiver o repositório clonado:

```bash
cd /caminho/para/private-skills
./install.sh --project
```

Reinicie o Claude Code após instalar.

---

### Instalação manual

Se preferir instalar sem o script, copie os arquivos da pasta `skills/` para o destino desejado:

**Global:**
```bash
mkdir -p ~/.claude/skills
cp skills/*.md ~/.claude/skills/
```

**Projeto único:**
```bash
mkdir -p .claude/skills
cp /caminho/para/private-skills/skills/*.md .claude/skills/
```

Reinicie o Claude Code após copiar.

---

## Atualização

Para atualizar para a versão mais recente:

```bash
cd /caminho/para/private-skills
git pull
./install.sh           # global
./install.sh --project # projeto específico
```

O script detecta automaticamente o que mudou e atualiza apenas os arquivos necessários.

---

## Desinstalação

```bash
./install.sh --uninstall           # remove da instalação global
./install.sh --uninstall --project # remove do projeto atual
```

---

## Como funciona

Cada skill é um arquivo `.md` que instrui o Claude Code sobre como se comportar quando o comando é invocado. Não há subagentes, não há arquivos intermediários de planejamento — o Claude executa diretamente na conversa.

**Mini-plano:** os comandos `/private-task`, `/private-fix` e `/private-doc` apresentam um plano inline na conversa antes de executar, para tarefas não-triviais. O plano fica na conversa — não cria arquivos em disco. Você aprova antes de qualquer mudança ser feita.

**Estado de sessão (efêmero):** o `/private-end` salva um arquivo `.session.md` na raiz do projeto com o resumo do que foi feito, pendências e decisões. O `/private-start` lê esse arquivo para retomar o contexto na próxima sessão. Por padrão, o `.session.md` é **gitignorado** — gera ruído em PRs e pode conter notas pessoais. Versionar é opt-in.

**Memória persistente (duradoura):** os skills também alimentam a memória persistente do Claude Code (`~/.claude/projects/<projeto>/memory/`) com fatos que sobrevivem entre sessões: o que o projeto faz, decisões arquiteturais, preferências do usuário e referências externas. Estado da última sessão **não** vai para lá — isso é o `.session.md`.

---

## Relação com skills nativos do Claude Code

O Claude Code já oferece skills nativos como `/init` (gera `CLAUDE.md`), `/review` e `/security-review`. Os comandos `/private-*` **coexistem** com eles e cobrem casos parcialmente sobrepostos:

| Caso | Use o nativo | Use o privado |
|---|---|---|
| Gerar `CLAUDE.md` rapidamente em projeto novo | `/init` | `/private-create` (em PT-BR, com fluxo de perguntas e estados A/B/C) |
| Revisar PR/branch antes de mergear | `/review` | — |
| Auditoria de segurança em mudanças pendentes | `/security-review` | — |
| Revisão local pré-commit (segurança + corretude + qualidade + consistência) | — | `/private-review` |
| Fluxo coeso de início/fim de sessão com `.session.md` e memória | — | `/private-start` + `/private-end` |
| Mini-plano em PT-BR antes de implementar feature/fix | — | `/private-task` + `/private-fix` |

Não há conflito: ambos os conjuntos ficam disponíveis simultaneamente.

---

## Estrutura do repositório

```
private-skills/
├── skills/
│   ├── private-start.md
│   ├── private-create.md
│   ├── private-task.md
│   ├── private-fix.md
│   ├── private-test.md
│   ├── private-doc.md
│   ├── private-review.md
│   └── private-end.md
├── install.sh
├── CLAUDE.md
├── CHANGELOG.md
├── LICENSE
└── README.md
```

---

## Customização

Os skills são arquivos Markdown simples com frontmatter YAML (`name`, `description`) seguido do corpo. Para ajustar o comportamento de qualquer comando, edite o arquivo correspondente em `~/.claude/skills/` (instalação global) ou `.claude/skills/` (instalação por projeto).

Por exemplo, para mudar o formato do briefing do `/private-start`, edite `~/.claude/skills/private-start.md` diretamente.

> **Atenção:** o frontmatter (`---name:...---`) é obrigatório. Sem ele, o Claude Code não registra o arquivo como skill invocável.

---

## Contribuindo

Para alterações no próprio repositório:

1. Edite o(s) skill(s) em `skills/`.
2. Bump de versão em `install.sh` (constante `VERSION`).
3. Adicione entrada em `CHANGELOG.md` seguindo Keep a Changelog.
4. Rode `bash -n install.sh && ./install.sh --help` antes de commitar.

---

## Licença

[MIT](LICENSE) — uso pessoal, comercial, modificação e redistribuição permitidos. Consulte o arquivo `LICENSE` para detalhes.
