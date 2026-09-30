# {{TITLE}} ({{MOD_NAME}}) – project rules

<!--
  Template from the factorio-modding skill. Adjust it, do not just keep it:
  delete what does not apply, add what your project needs. Lines in [brackets]
  are decisions you have to make.
-->

Factorio {{FACTORIO_VERSION}} mod. Plan: `docs/PLAN.md`, ideas: `docs/IDEAS.md`.

## docs/ – plans, ideas, feedback (not published)

`docs/` is in `.gitignore`. Layout and templates: skill `references/16-project-workflow.md`,
`scripts/templates/docs/`.

- `docs/PLAN.md` running plan, `docs/IDEAS.md` ideas with date and status – keep both current.
- Bigger work: plan first, get it approved, copy it to `docs/plans/YYYY-MM-DD_<version>-<topic>.md`
  and add it to the table in `docs/plans/README.md`. Implement milestone by milestone and wait for
  the go after each one.
- Every change to stored data gets a migration – nobody should have to start a new save.
- [If the mod has a GitHub wiki:] keep a clone in `docs/wiki/repo`, write the pages with each feature,
  commit locally, push with the release.

## Sources

Use the official API documentation, not memory or guesswork:

- https://lua-api.factorio.com/latest/ (runtime and prototype index, all subpages)
- https://lua-api.factorio.com/latest/auxiliary/mod-structure.html
- https://lua-api.factorio.com/latest/auxiliary/migrations.html
- https://wiki.factorio.com/Tutorial:Mod_settings
- https://mods.factorio.com/ (for how other mods solve a problem)

Reading installed mods locally (`~/.factorio/mods/`) is fine and often faster than any search.
Anything a skill or a tutorial claims gets checked against the official API before it is used.

## Other people's mods are read-only

Never patch, fix or update a mod that is not yours, not even for an obvious error. Name the
problem – file, line, cause – and leave it to its author. Tests that need foreign mods run on
throwaway copies, never in the real mod folder.

## Code

- One mod, one `storage`. Do not spread the logic over several mods.
- Areas in subfolders, no heap of files, keep files small (guide value: under 400 lines).
  A file that outgrows this gets split without being asked.
- Locale always in English **and** [your language]. Identifiers stay ASCII, texts use the real
  characters of the language.
- Migrations per https://lua-api.factorio.com/latest/auxiliary/migrations.html: renamed prototype →
  JSON migration; rebuilt `storage` → Lua migration, named `<version>-<topic>.lua`. It runs once per
  save **before** `on_configuration_changed`, so always check that the tables exist. The state
  module only adds missing tables, it never rewrites them.
- Never change the type of an entity silently: that creates new `unit_number`s and dangling
  references.
- Rebuilt a window? Raise its GUI version so old windows are closed instead of refreshed with the
  wrong layout.

## Performance (UPS and FPS must not drop)

- No `on_tick`. One `on_nth_tick` heartbeat with a fixed work budget per run.
- Event-driven instead of polling, and use event filters.
- Cap and cache path searches; only re-evaluate what changed.
- Update the GUI only while it is open, and only the rows that changed.

## Tests before every commit

- Everything at once: skill `scripts/test-all.sh` (lint per folder, headless tests in parallel).
  Report numbers only from the output of that run – never from old result files.
- Lint: `scripts/lint.sh . scripts` (lua-language-server with the FMTK types).
- Headless self test, and for anything performance-related a load test (`scripts/load-test.sh`).
- Mods you support: a compatibility test with them (`scripts/compat-test.sh`), foreign mods only
  linked, never changed.
- When grepping a log for problems, match broadly – `Error while (loading|running)`,
  `Failed to load mod`, `Missing required dependency`, `doesn't contain key`. A pattern that only
  looks for prototype errors reports "clean" on a broken run.

## Texts and releases

- `changelog.txt` in English with the standard categories (Features, Bugfixes, Changes, …).
- The mod portal description takes at most 35 000 characters; it comes from the English `README.md`
  (check with `wc -m README.md`).
- Commit, push and release only when asked. A push to the release branch publishes.

## Mod portal discussion

[Once the mod is on the portal:] once per session, at the author's first message, check
https://mods.factorio.com/mod/{{MOD_NAME}}/discussion (thread list and threads with new activity).
Note it in `docs/DISCUSSION.md` with the date, report what is new. The author answers; draft a reply
only when asked.

## Working style

Step by step, exactly what was asked. Do not run ahead, do not install or download anything
unasked. When the next step is obvious, offer it in one line and wait.
