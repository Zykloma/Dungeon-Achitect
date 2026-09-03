class_name GameSession
extends Node

var economy: EconomySystem
var floor: FloorController
var spawn_director: SpawnDirector
var combat_system: CombatSystem
var prestige_system: PrestigeSystem
var offline_system: OfflineSystem
var analytics_system: AnalyticsSystem

func setup(world_root: Node2D) -> void:
    economy = EconomySystem.new(); economy.name = "EconomySystem"; add_child(economy)
    floor = FloorController.new(); floor.name = "Floor_01"; world_root.add_child(floor); floor.setup(economy)
    spawn_director = SpawnDirector.new(); spawn_director.name = "SpawnDirector"; add_child(spawn_director); spawn_director.setup(economy, floor.build_service, floor.path_service, floor.grid, floor.heroes_root)
    combat_system = CombatSystem.new(); combat_system.name = "CombatSystem"; add_child(combat_system); combat_system.setup(floor.heroes_root, floor.monsters_root, economy)
    prestige_system = PrestigeSystem.new(); prestige_system.name = "PrestigeSystem"; add_child(prestige_system); prestige_system.setup(economy)
    offline_system = OfflineSystem.new(); offline_system.name = "OfflineSystem"; add_child(offline_system)
    analytics_system = AnalyticsSystem.new(); analytics_system.name = "AnalyticsSystem"; add_child(analytics_system)
    _load_if_available()

func serialize_state() -> Dictionary:
    return {"economy": economy.serialize(), "offline_ema": offline_system.serialize(), "floor": floor.grid.serialize()}

func _load_if_available() -> void:
    var data := SaveService.load_game()
    if data.is_empty(): return
    var meta: Dictionary = data.get("meta", {})
    AppState.dark_essence = int(meta.get("dark_essence", 0)); AppState.meta_upgrades = meta.get("meta_upgrades", {}); AppState.lifetime_stats.merge(meta.get("lifetime_stats", {}), true)
    var rewards := offline_system.reward_for(data)
    economy.restore(data.get("economy", {}))
    economy.add(&"gold", rewards.gold); economy.add(&"souls", rewards.souls); economy.add(&"mana", rewards.mana)
