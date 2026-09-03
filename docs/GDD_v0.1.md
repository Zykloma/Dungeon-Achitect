# Dungeon Architect — Roadmap & Production GDD v0.1

This repository implements the canonical GDD v0.1 created on 03.09.2026.

## Fixed production decisions
- Target: PC / Steam
- Engine baseline: Godot 4.7.x
- Presentation: 2D top-down, grid-based
- Logical cell: 64×64 px
- Starting floor: 48×36 cells
- Design pillars: BUILD, WATCH, OPTIMIZE, GROW, AUTOMATE
- Premium game; no mobile energy or pay-to-win systems

## Core loop
Build → attract heroes → watch → identify bottleneck → rebuild/upgrade → automate → defeat boss → prestige → restart stronger.

## Start economy
- Gold: 250
- Souls: 0
- Mana: locked / 0
- Fame: 0
- Dark Essence: 0

## Initial construction values
- Entrance: 5×5, free
- Corridor: 1 cell, 2 gold/cell
- Lure Treasure Room: 4×4, 50 gold, +0.02 Fame/s
- Goblin Den: 5×4, 120 gold, 3 Goblins
- Spike Trap: 1×2, 60 gold
- Skeleton Crypt: 5×5, 420 gold + 8 souls
- Spider Nest: 4×4, 650 gold + 12 souls
- Gold Mine: 6×5, 900 gold
- Training Hall: 5×4, 1200 gold + 20 souls
- Mana Source: 5×5, 2500 gold + 50 souls
- Troll Post: 5×5, 4500 gold + 60 souls
- Boss Room: 9×7, 7500 gold + 100 souls

Room upgrade: `ceil(base_cost * 1.10 * 1.65^(level-1))`.
Monster room stat multiplier: `1 + 0.18 * (level-1)`.

## Combat
Physical damage: `max(1, raw * 25 / (25 + armor))`.
Magic uses 30% of target armor.

Hero scaling:
- HP: `BaseHP * 1.18^(L-1)`
- Damage: `BaseDMG * 1.13^(L-1)`
- Armor: `BaseArmor + floor((L-1)/3)`
- Gold: `round(BaseGold * 1.15^(L-1))`
- Souls: `max(BaseSouls, round(BaseSouls * 1.08^(L-1)))`

## Fame bands
- 0–9: 14s, Raider/Militia
- 10–24: 12s, + Warrior
- 25–49: 10s, + Thief/Ranger
- 50–89: 8s, + Mage/Cleric
- 90–149: 6.5s, + Barbarian/Paladin
- 150+: 5s, + Royal Champion

Kill Fame = `0.25 × hero tier`; escape Fame = `3 × hero tier`.

## Prestige
Unlock target: Boss 1 defeated + RunScore ≥ 25,000.

`RunScore = gold_earned + 40*souls_earned + 5*mana_earned + 2500*boss_kills + 500*max_fame + 8000*(deepest_floor-1)`

`DarkEssence = floor(4 * (RunScore / 25000)^0.62)`, minimum 4 once eligible.

## Offline
Base cap: 12 hours. Reward uses stored 60-second EMA rates and 70% efficiency. Boss kills/relics/one-time events are not generated offline in the MVP.

## Architecture
Central services: ContentDB, EconomySystem, SpawnDirector, CombatSystem, GridService, PathService, BuildService, PrestigeSystem, OfflineSystem, AnalyticsSystem, SaveService.

The source code in this repository is the implementation reference. The complete long-form GDD is also retained in the project handoff archive generated alongside this repository version.