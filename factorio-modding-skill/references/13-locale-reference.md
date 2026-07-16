# Locale Reference (Factorio 2.1)

> **⚠️ Version-Hinweis:** Stand Factorio 2.1.11 experimental. Die Locale-API hat sich seit 2.0 nicht wesentlich geändert. Verify at [wiki.factorio.com/Tutorial:Localisation](https://wiki.factorio.com/Tutorial:Localisation).

## Locale Best Practices

- **Immer `en/` und `de/` bereitstellen** — Factorio hat eine große deutschsprachige Spielerbasis
- **Keine hartcodierten Texte** — Immer Locale-Keys verwenden: `player.print({"message.welcome"})` statt `player.print("Welcome")`
- **`{` `}` für LocalisedString** — In Lua: `{"item-name.my-item"}`, in .cfg: `my-item=My Item`

## locale/en/my-mod.cfg

```cfg
[item-name]
my-item=My Item

[item-description]
my-item=A useful item created by this mod.

[entity-name]
my-machine=My Machine

[entity-description]
my-machine=A powerful processing unit.

[recipe-name]
my-recipe=My Recipe

[technology-name]
my-tech=My Technology

[technology-description]
my-tech=Research this to unlock new possibilities.

[mod-name]
my-mod=My Mod Title

[mod-description]
my-mod=Description shown in mod portal.

[message]
welcome=Welcome to the mod!
updated=Mod updated to version __1__.
```

## locale/de/my-mod.cfg

```cfg
[item-name]
my-item=Mein Item

[item-description]
my-item=Ein nützliches Item, das von diesem Mod erstellt wurde.

[entity-name]
my-machine=Meine Maschine

[entity-description]
my-machine=Eine leistungsstarke Verarbeitungseinheit.

[recipe-name]
my-recipe=Mein Rezept

[technology-name]
my-tech=Meine Technologie

[technology-description]
my-tech=Erforsche dies, um neue Möglichkeiten freizuschalten.

[mod-name]
my-mod=Mein Mod Titel

[mod-description]
my-mod=Beschreibung, die im Mod-Portal angezeigt wird.

[message]
welcome=Willkommen beim Mod!
updated=Mod aktualisiert auf Version __1__.
```

## LocalisedString Patterns

```lua
-- Simple key
player.print({"message.welcome"})

-- With parameter (__1__ in .cfg)
player.print({"message.updated", "2.1.0"})

-- Concatenation (empty string prefix)
player.print({"", "Built ", {"entity-name.my-machine"}, " at ", tostring(x), ", ", tostring(y)})

-- Rich text
player.print({"", "[item=iron-plate]", " Iron Plate"})
player.print({"", "[entity=assembling-machine-3]", " Assembler"})
```
