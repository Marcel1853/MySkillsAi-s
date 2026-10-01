# MySkillsAi-s

🇩🇪 [Deutsche Fassung](README-de.md)

A collection of **skills for AI coding assistants** (made for Claude / Claude Code). A skill is a
folder with a `SKILL.md` and reference files: knowledge, checked pitfalls, templates and tools that
the AI reads when a task fits. More skills will be added over time.

## Skills

| Skill | Version | What it is for |
|---|---|---|
| [factorio-modding-skill](factorio-modding-skill) | 1.0.0 | Writing, testing and publishing **Factorio 2.1 mods** (incl. Space Age) |

### factorio-modding-skill

My first skill. It grew while building the train dispatcher
[Unified Train Logistics](https://mods.factorio.com/mod/UTLogistics) – but it is meant for **any**
Factorio mod, not only train mods.

- **API reference** for Factorio 2.1: data lifecycle, prototypes, runtime, GUI, circuits, trains,
  rendering, Space Age (planets, platforms, asteroids, quality), locale.
- **Checked pitfalls** – things that look right but fail in the game, each found and verified in a
  real project.
- **Testing**: headless self tests, load tests, compatibility tests with other mods, scenario checks,
  screenshots with graphics, tips & tricks scenes, lint like in VS Code (FMTK).
- **Publishing**: packaging, changelog, mod portal, GitHub release workflow.
- **Project workflow** for long projects with an AI: plan, ideas, approved plans, mod portal
  discussion log, wiki, blueprints turned into test scenarios.
- **Examples** that load and run in Factorio 2.1 (checked with `scripts/check-examples.py`).

Always verify against the official API documentation: https://lua-api.factorio.com/latest/ –
Factorio 2.1 still changes.

## Using a skill

- **Claude Code:** copy the skill folder (e.g. `factorio-modding-skill/`) to `~/.claude/skills/`
  (for all your projects) or to `.claude/skills/` inside a project.
- **Other tools:** give the AI the `SKILL.md` and let it read the referenced files when needed.

## Versions and updates

Each skill has a version line at the top of its `SKILL.md` and a `changelog.txt` (Factorio format).
A copied skill does **not** update itself, and it tells the AI not to check on its own. Ask your AI
"is there a newer version of the skill?" – it compares with this repository, shows what changed
and replaces files only after you agree.

## How it is made

The skills are written with the help of AI (Claude by Anthropic) and tested in real projects. I
decide what goes in and test the results myself. Corrections and ideas are welcome – open an issue.

## License

[MIT](LICENSE)
