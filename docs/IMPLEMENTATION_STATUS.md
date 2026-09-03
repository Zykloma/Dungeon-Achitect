# Implementation Status — v0.2 code-prep pass

## Implemented / prepared from GDD v0.1
- Godot 4.7.x project skeleton and 2D top-down grid baseline
- 64 px logical cells, 48×36 starting floor
- Content definitions for all 10 GDD heroes, all 10 GDD monsters and 12 initial rooms/objects
- All 12 GDD research entries with exact rank caps, cost curves and effect values
- All 10 GDD meta upgrades with cost/effect APIs
- Hero level formulas, physical/magic armor formulas, room scaling, prestige score and Dark Essence formula
- Start economy, Gold/Souls/Mana/Fame state and lifetime counters
- Fame spawn bands, group sizes, hero pools and level ranges
- Room build service with occupancy, adjacency validation, research/meta construction discounts and room upgrades
- Full room layout serialization/restoration with stable instance IDs and room levels
- Central AStarGrid2D path service + cache invalidation by grid revision
- Auto hero spawn, treasure target, return to entrance / escape
- GDD spike trap behavior: enter trigger, detect chance, thief disable, damage scaling and reset scaling
- Monster room slot counts and room-local respawn timers for Goblin/Skeleton/Spider/Troll rooms
- Production: Goldmine, Manaquelle; treasure Fame; Trainingshalle adjacency damage buff
- Research effects connected to monster HP/damage, trap damage/reset, treasure Fame, production, loot, spawn interval, room costs
- Meta effects connected to starting Gold, loot, monster stats, room costs, spawn interval and offline cap
- Combat preparation for Goblin pack bonus, Spider web, Slime corrosion, Wraith evasion, Troll regen, Vampire lifesteal, Demon cleave
- Hero preparation for Raider retreat, Warrior block, Ranger/Mage range, Mage splash, Cleric heal, Barbarian rage, Paladin anti-undead/magic resistance
- Kill rewards and Fame gains on death/escape
- 60-second EMA offline aggregation sampled every 10 seconds; 70% payout; clock rollback protection; Fame offline cap
- Atomic-ish temp-save swap, backup fallback and v1→v2 migration defaults
- Prestige transaction API that resets run state while preserving DE/meta/lifetime stats
- Analytics containers for traps/rooms
- Debug/playable HUD with build selection, room selection/upgrades, research purchasing and prestige state

## Intentionally still open
- Proper authored TileMapLayer tileset and final art pipeline
- Door-edge objects and explicit per-room doorway editing; current walkability uses whole room footprints
- Full threat model from the GDD and richer movement/blocking during combat
- Skeleton one-time resurrection and Champion group war cry
- Fire-damage tracking for Troll regeneration condition
- Boss content/encounter stats: GDD v0.1 specifies boss room/progression but not Boss 1 base stats, so code does not invent canonical numbers
- Full sell/demolish flow and path-safety validation before demolition
- Save of transient heroes/monsters/trap cooldowns (MVP can intentionally resume from stable dungeon state)
- Boss reward pipeline and automatic `PrestigeSystem.register_boss_kill()` integration
- Heatmap visualization UI
- Automation managers
- Multiple floors, biomes, relics, world map, expeditions, Steamworks

## Required first editor pass
This code was prepared without a Godot executable in the current runtime. Open in Godot 4.7.x and fix any parser/runtime differences before treating v0.2 as a tested build. The highest-risk areas are typed Dictionary/Array Variant access and UI sizing, not the data/formula design.
