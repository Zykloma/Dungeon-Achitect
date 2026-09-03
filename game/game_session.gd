class_name GameSession
extends Node

signal offline_rewards_applied(rewards: Dictionary)
signal prestige_completed(dark_essence_gained: int)

var economy: EconomySystem
var meta: MetaProgressionSystem
var research: ResearchSystem
var floor: FloorController
var spawn_director: SpawnDirector
var combat_system: CombatSystem
var prestige_system: PrestigeSystem
var offline_system: OfflineSystem
var analytics_system: AnalyticsSystem
var room_effect_system: RoomEffectSystem
var monster_spawner_system: MonsterSpawnerSystem
var trap_system: TrapSystem
var autosave_timer := 0.0
const AUTOSAVE_SECONDS := 30.0

func setup(world_root: Node2D) -> void:
    var save_data := SaveService.load_game()
    _restore_meta(save_data)

    meta = MetaProgressionSystem.new()
    meta.name = "MetaProgressionSystem"
    add_child(meta)

    economy = EconomySystem.new()
    economy.name = "EconomySystem"
    add_child(economy)
    if save_data.is_empty():
        economy.reset_run(meta.starting_gold())
    else:
        economy.restore(save_data.get("economy", {}))

    research = ResearchSystem.new()
    research.name = "ResearchSystem"
    add_child(research)
    research.setup(economy)
    research.restore(save_data.get("research", {}))

    floor = FloorController.new()
    floor.name = "Floor_01"
    world_root.add_child(floor)
    floor.setup(economy, research, meta)

    analytics_system = AnalyticsSystem.new()
    analytics_system.name = "AnalyticsSystem"
    add_child(analytics_system)
    analytics_system.restore(save_data.get("analytics", {}))

    room_effect_system = RoomEffectSystem.new()
    room_effect_system.name = "RoomEffectSystem"
    add_child(room_effect_system)
    room_effect_system.setup(economy, floor.build_service, research, meta)

    monster_spawner_system = MonsterSpawnerSystem.new()
    monster_spawner_system.name = "MonsterSpawnerSystem"
    add_child(monster_spawner_system)
    monster_spawner_system.setup(floor.build_service, floor.monsters_root, research, meta, room_effect_system)

    if not save_data.is_empty() and save_data.has("floor"):
        monster_spawner_system.clear_all()
        floor.restore(save_data.get("floor", {}))

    spawn_director = SpawnDirector.new()
    spawn_director.name = "SpawnDirector"
    add_child(spawn_director)
    spawn_director.setup(economy, floor.build_service, floor.path_service, floor.grid, floor.heroes_root, research, meta)

    combat_system = CombatSystem.new()
    combat_system.name = "CombatSystem"
    add_child(combat_system)
    combat_system.setup(floor.heroes_root, floor.monsters_root, economy)

    prestige_system = PrestigeSystem.new()
    prestige_system.name = "PrestigeSystem"
    add_child(prestige_system)
    prestige_system.setup(economy)
    prestige_system.restore(save_data.get("prestige", {}))

    offline_system = OfflineSystem.new()
    offline_system.name = "OfflineSystem"
    add_child(offline_system)
    offline_system.setup(economy, meta)
    offline_system.restore(save_data.get("offline_ema", {}))
    spawn_director.hero_killed.connect(offline_system.record_kill)

    trap_system = TrapSystem.new()
    trap_system.name = "TrapSystem"
    add_child(trap_system)
    trap_system.setup(floor.build_service, floor.heroes_root, research, analytics_system)

    if not save_data.is_empty():
        _apply_offline_rewards(save_data)

func _process(delta: float) -> void:
    autosave_timer += delta
    if autosave_timer >= AUTOSAVE_SECONDS:
        autosave_timer = 0.0
        SaveService.save_game(self)

func serialize_state() -> Dictionary:
    return {
        "economy": economy.serialize(),
        "research": research.serialize(),
        "prestige": prestige_system.serialize(),
        "offline_ema": offline_system.serialize(),
        "analytics": analytics_system.serialize(),
        "floor": floor.serialize(),
    }

func perform_prestige() -> bool:
    if not prestige_system.can_prestige():
        return false
    var gained := prestige_system.available_dark_essence()
    AppState.dark_essence += gained
    AppState.lifetime_stats["prestiges"] = int(AppState.lifetime_stats.get("prestiges", 0)) + 1
    spawn_director.clear_all()
    monster_spawner_system.clear_all()
    research.reset_run_research()
    economy.reset_run(meta.starting_gold())
    prestige_system.reset_run_counters()
    analytics_system.reset_run()
    floor.build_service.clear_all()
    floor.create_starter_layout()
    offline_system.reset_run()
    AppState.reset_run_stats()
    SaveService.save_game(self)
    prestige_completed.emit(gained)
    return true

func _restore_meta(save_data: Dictionary) -> void:
    if save_data.is_empty():
        return
    var meta_data: Dictionary = save_data.get("meta", {})
    AppState.dark_essence = int(meta_data.get("dark_essence", 0))
    AppState.meta_upgrades.clear()
    var saved_meta: Dictionary = meta_data.get("meta_upgrades", {})
    for key in saved_meta:
        AppState.meta_upgrades[StringName(str(key))] = int(saved_meta[key])
    var saved_lifetime: Dictionary = meta_data.get("lifetime_stats", {})
    AppState.lifetime_stats.merge(saved_lifetime, true)

func _apply_offline_rewards(save_data: Dictionary) -> void:
    var rewards := offline_system.reward_for(save_data)
    economy.add(&"gold", float(rewards["gold"]))
    economy.add(&"souls", float(rewards["souls"]))
    if research.mana_unlocked():
        economy.add(&"mana", float(rewards["mana"]))
    economy.add(&"fame", float(rewards["fame"]))
    offline_rewards_applied.emit(rewards)
