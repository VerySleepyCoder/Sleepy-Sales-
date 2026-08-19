# Sleepy Sales — Agent Library

A collection of ready-to-use **subagents** for AI coding tools (Claude Code and
friends). Each agent is a focused "mode" — a specialist with a clear job,
operating principles, and a definition of done — packaged as a single Markdown
file with YAML frontmatter.

Drop them into your tool's agents directory and activate them by name.

## Divisions

Agents are organized into divisions so you can install only what you need.

| Division | Agents |
| --- | --- |
| **engineering** | frontend-developer, backend-architect, devops-automator, mobile-app-builder, rapid-prototyper, test-writer-fixer |
| **design** | ui-designer, ux-researcher |
| **product** | sprint-prioritizer, feedback-synthesizer |
| **marketing** | growth-hacker, content-creator |
| **sales** | sales-development-rep, account-executive |
| **testing** | api-tester, performance-benchmarker |
| **operations** | analytics-reporter, support-responder, infrastructure-maintainer |

Run `./scripts/install.sh --list` to see the current, authoritative list.

## Install

```bash
# Install all agents to your Claude Code directory
./scripts/install.sh --tool claude-code

# Or manually copy a category if you only want one division
cp engineering/*.md ~/.claude/agents/

# Then activate any agent in your Claude Code sessions:
# "Hey Claude, activate Frontend Developer mode and help me build a React component"
```

### More install options

```bash
./scripts/install.sh --list                        # list every division and agent
./scripts/install.sh --tool claude-code            # install everything
./scripts/install.sh --tool claude-code engineering design   # install specific divisions
./scripts/install.sh --tool claude-code --dry-run  # preview without writing anything
./scripts/install.sh --tool claude-code --force    # overwrite existing agent files
./scripts/install.sh --dest ~/some/other/dir       # install to a custom directory
```

The `--tool` flag picks the destination directory automatically:

| Tool | Destination |
| --- | --- |
| `claude-code` (default) | `~/.claude/agents/` |
| `cursor` | `~/.cursor/agents/` |
| `opencode` | `~/.config/opencode/agents/` |

By default the installer **won't overwrite** an agent file you've locally
modified — it skips it and tells you to pass `--force` if you really want to
replace it. Identical files are copied through without complaint, so re-running
the installer to pick up updates is safe.

## Using an agent

Once installed, activate an agent by referring to it in a normal session:

> "Activate **Frontend Developer** mode and help me build a responsive pricing
> table."

> "Use the **Backend Architect** to design the API for a comments feature."

In Claude Code you can also invoke a subagent explicitly (for example
`@frontend-developer`) depending on your version. The agent's `name` in the
frontmatter is what you reference; its `description` tells the tool when to
reach for it automatically.

## Anatomy of an agent

Every agent is a Markdown file with YAML frontmatter:

```markdown
---
name: frontend-developer
description: When this agent should be used (used for auto-selection).
tools: Read, Write, Edit, Grep, Glob, Bash   # optional — omit to inherit all tools
model: sonnet                                # optional
---

The system prompt: who the agent is, its operating principles,
its workflow, and its definition of done.
```

- **name** — the identifier you activate; keep it kebab-case and unique.
- **description** — when the tool should pick this agent; write it in terms of
  the trigger, e.g. "Use this agent to …".
- **tools** *(optional)* — restrict the agent to specific tools; omit to inherit
  the full tool set.
- **model** *(optional)* — pin a model for the agent.

## Adding your own agent

1. Create `division/your-agent.md` (make a new division folder if needed — any
   top-level folder that contains `.md` files is auto-discovered by the
   installer).
2. Add the frontmatter and a focused system prompt following the format above.
3. Run `./scripts/install.sh --list` to confirm it's discovered, then install.

## Repository layout

```
.
├── scripts/
│   └── install.sh          # installer (supports --tool, --list, --dry-run, --force, --dest)
├── engineering/            # one folder per division; each holds agent *.md files
├── design/
├── product/
├── marketing/
├── sales/
├── testing/
├── operations/
└── README.md
```

## License

[MIT](LICENSE)
