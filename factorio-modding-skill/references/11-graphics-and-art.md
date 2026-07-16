# Factorio Graphics & Art Style Guide (Reference Only)

> **⚠️ Version-Hinweis:** Diese Datei enthält **keine** Factorio Lua API-Informationen. Sie dient ausschließlich als stilistischer Referenzpunkt für Grafik-Erstellung und AI-Prompt-Templates. Für technische Sprite-Definitionen (Animation, working_visualisations, etc.) siehe `references/02-prototype-stage.md` und die offizielle Prototype-Doku unter [lua-api.factorio.com/latest/](https://lua-api.factorio.com/latest/).

---

## Kurzzusammenfassung

Diese Datei wurde von einer ausführlichen Grafik- und Prompt-Anleitung auf diesen Verweis reduziert, da Grafik-Style-Guides keine API-Referenz darstellen und nicht in einen API-getriebenen Skill gehören.

### Kernregeln (Kurzfassung)

1. **Lichtquelle**: Oben-links, Schatten nach unten-rechts
2. **Stil**: Industrial Dieselpunk — Rost, Ruß, Abnutzung, kein sauberes Sci-Fi
3. **Farbpalette**: Schiefergrau, Eisen, oxidiertes Kupfer, Rostorange, Industrieschmutz
4. **Projektion**: Isometrisch/orthografisch, gitterausgerichtet
5. **Icons**: 64×64 px, Items; 256×256 px, Technologies
6. **Sprite-Sheets**: `frame_count`, `line_length`, `animation_speed` in Prototypen definieren
7. **Glow-Mask**: `draw_as_glow = true` in `working_visualisations` für emissive Lichteffekte (2.0+)
8. **Farbmasken**: `apply_runtime_tint = true` für dynamische Farbänderungen

### Technische Prototype-Referenz

Für die korrekte technische Definition von Sprites, Animationen und Grafik-Properties in Prototypen, siehe:
- `references/02-prototype-stage.md` — Entity/Item-Prototypen mit Grafik-Properties
- `references/03-space-age-prototypes.md` — Space Age Grafik-Erweiterungen
- [Offizielle Prototype-Doku](https://lua-api.factorio.com/latest/) — Autoritative Quelle für alle Prototype-Properties
