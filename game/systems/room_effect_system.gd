class_name RoomEffectSystem
extends Node

var economy: EconomySystem
var build_service: BuildService
var research: ResearchSystem
var meta: MetaProgressionSystem
var tick_accumulator := 0.0
const TICK_SECONDS := 0.25

func setup(eco: EconomySystem, build: BuildService, research_system: ResearchSystem, meta_system: MetaProgressionSystem) -> void:
    economy = eco
    build_service = build
    research = research_system
    meta = meta_system

func _process(delta: float) -> void:
    if economy == null or build_service == null:
        return
    tick_accumulator += delta
    if tick_accumulator < TICK_SECONDS:
        return
    var dt := tick_accumulator
    tick_accumulator = 0.0
    for room in build_service.built_rooms:
        if not is_instance_valid(room):
            continue
        var def := ContentDB.room(room.definition_id)
        if def == null:
            continue
        match def.id:
            &"room.lure_treasure":
                var fame_rate := def.base_fame_per_second * research.treasure_fame_multiplier()
                economy.add(&"fame", fame_rate * dt)
            &"room.gold_mine":
                var gold_rate := 3.0 * _production_level_multiplier(room.level)
                gold_rate *= research.gold_production_multiplier() * meta.gold_multiplier()
                economy.add(&"gold", gold_rate * dt)
            &"room.mana_source":
                if research.mana_unlocked():
                    var mana_rate := 1.0 * _production_level_multiplier(room.level)
                    mana_rate *= research.mana_production_multiplier()
                    economy.add(&"mana", mana_rate * dt)

func training_damage_multiplier_for(room: RoomInstance) -> float:
    if build_service == null or room == null:
        return 1.0
    var bonus := 0.0
    for other in build_service.built_rooms:
        if not is_instance_valid(other) or other == room or other.definition_id != &"room.training_hall":
            continue
        if build_service.rooms_are_adjacent(room, other):
            bonus += 0.12 + 0.03 * float(max(0, other.level - 1))
    return 1.0 + bonus

func _production_level_multiplier(level: int) -> float:
    return 1.0 + 0.25 * float(max(0, level - 1))
