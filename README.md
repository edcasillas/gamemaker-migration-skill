# GameMaker Migration Skill

Codex skill for migrating legacy Game Maker projects from GM4/GM5 `.gmd` sources through GameMaker Studio 1.4 and onward to modern GameMaker or HTML5.

This repository is meant to be used as a standalone skill repository and can be included in project repos as a Git submodule.

## What This Skill Covers

- GM4 to GM5 source recovery and conversion.
- GameMaker Studio 1.4 import cleanup.
- Broken imported Drag and Drop actions.
- Obsolete Game Maker functions.
- Resource name collisions after import.
- HTML5/browser runtime validation.
- MIDI/audio conversion support for web export.

## Using It

The agent-facing entrypoint is:

```text
SKILL.md
```

That file contains the skill frontmatter and the workflow instructions Codex uses when the skill is triggered.

Bundled supporting material lives in:

- `references/` for migration notes and validation workflows.
- `scripts/` for repeatable helper scripts.
- `assets/` for bundled tools and other non-context assets.
- `agents/` for UI metadata.

`references/fantasma-migration-lessons.md` is an evidence-backed case study of a successful GM5/GMS1.4 -> GMS2/HTML5 migration. Use it for reusable migration patterns, not as active-project guidance.

## Optional Companion Skill

For current GameMaker command-line development, `.yyp` compile/run/package workflows, ResourceTool, GameMaker Manual lookup, and GX.Games packaging or publishing, use the optional companion skill:

```text
https://github.com/edcasillas/gamemaker-development-skill
```

Install it as a direct checkout:

```sh
git clone https://github.com/edcasillas/gamemaker-development-skill.git .agents/skills/gamemaker-development
```

Or install it as a Git submodule:

```sh
git submodule add https://github.com/edcasillas/gamemaker-development-skill.git .agents/skills/gamemaker-development
```

Both skills are independent. Install only the one that matches the project work, or install both when a project needs legacy migration guidance and modern GameMaker CLI workflows.

## Notes For Maintainers

Keep project-specific migration discoveries in the target project repo, not here, unless they generalize across legacy Game Maker migrations.

When updating the skill, keep `SKILL.md` concise and move detailed supporting material into `references/` so agents can load it only when needed.
