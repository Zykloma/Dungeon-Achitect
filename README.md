# Dungeon Architect

Godot 4.7.x 2D top-down prototype based on `docs/GDD_v0.1.md`.

## Current playable milestone

- 48×36 logical grid at 64 px/cell
- Entrance, corridor, lure treasure room, goblin den, spike trap
- Start economy: 250 gold
- Fame-driven automatic hero spawning
- AStarGrid2D path service with path cache
- Heroes walk to a lure treasure room and then escape through the entrance
- Goblin den spawns defenders; proximity combat and kill rewards are active
- Room placement/validation and costs
- Save/load foundation, offline reward calculation, prestige formulas
- Debug HUD and build palette

## Controls

- `1` Corridor
- `2` Lure Treasure Room
- `3` Goblin Den
- `4` Spike Trap
- Left mouse: build at hovered grid cell
- Right mouse / `Esc`: cancel build mode
- Middle mouse drag: pan camera
- Mouse wheel: zoom
- `F5`: save

The first goal is the GDD milestone: entrance → build path/treasure → automatic hero spawn → pathfinding → treasure → exit, with combat layered on top.
