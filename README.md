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

## Notes For Maintainers

Keep project-specific migration discoveries in the target project repo, not here, unless they generalize across legacy Game Maker migrations.

When updating the skill, keep `SKILL.md` concise and move detailed supporting material into `references/` so agents can load it only when needed.
