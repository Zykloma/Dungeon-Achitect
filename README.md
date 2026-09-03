# Dungeon Architect

Godot 4.7.x 2D top-down idle/dungeon-management prototype based on `docs/GDD_v0.1.md`.

## v0.2 code-prep scope

The repository now contains a substantially expanded MVP foundation:

- 48×36 logical dungeon grid at 64 px/cell
- Central `AStarGrid2D` path service and cached path revisions
- Entrance, corridors and all initial GDD room definitions
- Room construction, selection and upgrades with GDD cost formula
- Research and meta-progression cost/effect APIs using the GDD values
- Goldmine, Manaquelle, treasure Fame and Trainingshalle effects
- Monster room slots and local respawn timers
- Spike trap trigger/detection/disarm/reset behavior
- Fame-driven automatic hero spawning and GDD hero level bands
- Extended hero/monster combat ability preparation
- Full stable dungeon-room save/restore including levels and instance IDs
- 10-second sampling / 60-second EMA offline progression
- Prestige transaction foundation preserving Dark Essence/meta/lifetime data
- Debug UI for building, upgrades, research and Prestige availability

See `docs/IMPLEMENTATION_STATUS.md` for exact implemented/open items.

## Controls

- `1` Corridor
- `2` Lure Treasure Room
- `3` Goblin Den
- `4` Spike Trap
- `5` Skeleton Crypt
- `6` Spider Nest
- `7` Gold Mine
- `8` Training Hall
- `9` Mana Source
- `0` Troll Post
- `B` Boss Room
- `U` upgrade selected room
- Left mouse: build/select
- Right mouse / `Esc`: cancel build mode
- Middle mouse drag: pan camera
- Mouse wheel: zoom
- `F5`: save

## Important

The code-prep pass was created without a Godot executable in the execution environment. Open the project in Godot 4.7.x and do a parser/runtime verification pass before treating this revision as a tested build.
