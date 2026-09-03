# Implementation Status — v0.1

## Implemented from GDD
- Godot 4.7.x project skeleton and 2D top-down grid baseline
- 64 px logical cells, 48×36 starting floor
- Resource definitions for all 10 GDD heroes, all 10 GDD monsters, and 12 initial rooms/objects
- Hero level formulas, physical/magic armor formulas, room scaling, prestige score and Dark Essence formula
- Start economy (250 gold), Gold/Souls/Mana/Fame state and lifetime counters
- Fame spawn bands, group sizes, hero pools and level ranges
- Room build service with occupancy and adjacency validation
- Central AStarGrid2D path service + cache invalidation by grid revision
- Entrance, corridor, lure treasure room, goblin den, spike trap placement
- Auto hero spawn, treasure target, return to entrance / escape
- Visible hero/monster debug rendering and proximity combat
- Kill rewards and Fame gains on death/escape
- Offline reward formula foundation
- Save service with backup file and version field
- Prestige system calculation foundation
- Analytics data containers

## Still required for full GDD / later milestones
- Proper TileMapLayer art pipeline and authored tileset
- Door-edge connectivity and multi-door room routing
- Trap trigger behavior, detection/disarm and reset timers
- Monster respawning and all individual monster abilities
- Hero class abilities
- Research UI/system and upgrade purchasing
- Production rooms and support-room adjacency buffs
- Boss encounters and prestige reset transaction
- Accurate 60s EMA sampling for offline rewards
- Save restoration of complete placed room layout/entities
- Heatmap/analytics UI
- Automation managers
- Multiple floors, biomes, relics, world map, expeditions, Steamworks

This repository is an executable foundation/vertical-slice implementation, not a claim that the full 1.0 content scope can be completed in a single coding pass.
