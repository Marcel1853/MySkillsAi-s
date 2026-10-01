# Changelog – factorio-modding-skill

Version in `SKILL.md` (line "Skill version"). Newest first. Repository:
https://github.com/Marcel1853/MySkillsAi-s/tree/main/factorio-modding-skill

## 1.0.0 – 2026-10-01 – first public version

- **All 14 examples load and run in Factorio 2.1** (checked headless with `scripts/check-examples.py`):
  2.x recipe format, valid setting types, no graphics/sounds from non-existing mods, complex
  prototypes via `deepcopy`, real Space Age asteroid and autoplace helpers, `train_manager.get_trains`.
- **Project workflow** (`references/16-project-workflow.md`): `docs/` folder with plan, ideas,
  approved plans, mod portal discussion log, local wiki, screenshots, blueprints → scenarios.
  Templates in `scripts/templates/docs/`.
- **General tools**: `test-all.sh`, `compat-test.sh`, `load-test.sh`, `scenario-check.sh`,
  `play-with-mods.sh`, `blueprint2lua.py`, `check-examples.py`.
- **Pitfalls** (`references/15-pitfalls.md`): track builder via `LuaRailEnd.get_rail_extensions`,
  path between two stops (`starts`), `train_state` in 2.1, lost departure on `no_path`, power poles
  without copper wire, Space Exploration (space elevator, interface, headless limits), prototype
  errors found in old examples.
- Templates: `track-builder`, `fake-remote-test`; `release.yml` on `actions/checkout@v5`, `ubuntu-24.04`.
- `CLAUDE.md` template extended (docs folder, plans, wiki, bundled tests, portal discussion).
- Update rule in `SKILL.md`: check for a newer version only when the user asks.

## 0.3 – 2026-09-26 … 09-27

- Lessons from a real project (`14-testing-and-publishing.md`, `15-pitfalls.md`), `CLAUDE.md`
  template, release workflow also sets the portal description, explain panel for scenarios,
  screenshot template with a full wiki run as example.

## 0.2 – 2026-09-19 … 09-20

- Script that regenerates the defines reference from the official API; notes on blueprints and
  mod settings.

## 0.1 – 2026-07-16

- First version: API reference for Factorio 2.1 (2.1.11 stamps), examples, evals.
