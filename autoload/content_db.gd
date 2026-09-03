extends Node

var heroes: Dictionary = {}
var monsters: Dictionary = {}
var rooms: Dictionary = {}

func _ready() -> void:
    _seed_definitions()

func hero(id: StringName) -> HeroDefinition:
    return heroes.get(id)

func monster(id: StringName) -> MonsterDefinition:
    return monsters.get(id)

func room(id: StringName) -> RoomDefinition:
    return rooms.get(id)

func _seed_definitions() -> void:
    _add_hero(&"hero.raider", "Plünderer", 1, 45, 5, 1.3, 0, 75, 0.00, 12, 0, &"seek_treasure")
    _add_hero(&"hero.militia", "Milizionär", 1, 80, 8, 1.2, 1, 70, 0.05, 20, 1, &"frontline")
    _add_hero(&"hero.warrior", "Krieger", 2, 150, 15, 1.2, 4, 65, 0.05, 40, 2, &"block")
    _add_hero(&"hero.thief", "Dieb", 2, 105, 18, 0.9, 1, 90, 0.35, 50, 2, &"disarm")
    _add_hero(&"hero.ranger", "Waldläufer", 2, 115, 14, 1.1, 2, 75, 0.15, 60, 2, &"ranged")
    _add_hero(&"hero.mage", "Magier", 3, 90, 28, 1.8, 0, 60, 0.10, 85, 4, &"splash_magic")
    _add_hero(&"hero.cleric", "Kleriker", 3, 130, 10, 1.4, 3, 60, 0.10, 90, 4, &"heal")
    _add_hero(&"hero.barbarian", "Barbar", 4, 230, 35, 1.5, 2, 75, 0.05, 130, 6, &"rage")
    _add_hero(&"hero.paladin", "Paladin", 5, 320, 28, 1.3, 8, 55, 0.15, 180, 8, &"holy")
    _add_hero(&"hero.champion", "Königlicher Champion", 8, 650, 55, 1.2, 12, 65, 0.20, 500, 20, &"war_cry")

    _add_monster(&"monster.goblin", "Goblin", 55, 8, 1.1, 0, 85, [&"living"], &"pack_instinct")
    _add_monster(&"monster.skeleton", "Skelett", 95, 12, 1.4, 2, 60, [&"undead"], &"rise_again")
    _add_monster(&"monster.spider", "Höhlenspinne", 70, 6, 0.9, 0, 90, [&"beast"], &"web")
    _add_monster(&"monster.slime", "Schleim", 160, 9, 1.6, 0, 40, [&"ooze"], &"corrosion")
    _add_monster(&"monster.orc", "Ork-Wächter", 220, 22, 1.4, 5, 65, [&"living"], &"taunt")
    _add_monster(&"monster.acolyte", "Dunkler Akolyth", 90, 16, 1.5, 0, 55, [&"living", &"magic"], &"dark_bolt")
    _add_monster(&"monster.wraith", "Wraith", 120, 20, 1.2, 0, 80, [&"undead"], &"evasion")
    _add_monster(&"monster.troll", "Troll", 500, 45, 2.2, 8, 45, [&"living"], &"regeneration")
    _add_monster(&"monster.vampire", "Vampir", 340, 32, 1.3, 4, 80, [&"undead"], &"lifesteal")
    _add_monster(&"monster.demon", "Dämonenbrut", 850, 70, 1.8, 10, 55, [&"demon"], &"cleave")

    _add_room(&"room.entrance", "Dungeon-Eingang", Vector2i(5, 5), 0, 0, 1, &"entrance")
    _add_room(&"room.corridor", "Korridor", Vector2i(1, 1), 2, 0, 1, &"corridor")
    _add_room(&"room.lure_treasure", "Lockschatzkammer", Vector2i(4, 4), 50, 0, 10, &"treasure", &"", 0.02, 100)
    _add_room(&"room.goblin_den", "Goblinhöhle", Vector2i(5, 4), 120, 0, 10, &"monster", &"monster.goblin")
    _add_room(&"room.spike_trap", "Stachelfalle", Vector2i(1, 2), 60, 0, 10, &"trap")
    _add_room(&"room.skeleton_crypt", "Skelettgruft", Vector2i(5, 5), 420, 8, 10, &"monster", &"monster.skeleton")
    _add_room(&"room.spider_nest", "Spinnennest", Vector2i(4, 4), 650, 12, 10, &"monster", &"monster.spider")
    _add_room(&"room.gold_mine", "Goldmine", Vector2i(6, 5), 900, 0, 10, &"production")
    _add_room(&"room.training_hall", "Trainingshalle", Vector2i(5, 4), 1200, 20, 10, &"support")
    _add_room(&"room.mana_source", "Manaquelle", Vector2i(5, 5), 2500, 50, 10, &"production")
    _add_room(&"room.troll_post", "Troll-Wachposten", Vector2i(5, 5), 4500, 60, 10, &"monster", &"monster.troll")
    _add_room(&"room.boss", "Bosskammer", Vector2i(9, 7), 7500, 100, 10, &"boss")

func _add_hero(id: StringName, title: String, tier: int, hp: float, dmg: float, interval: float, armor: float, speed: float, detect: float, gold: float, souls: float, ability: StringName) -> void:
    var d := HeroDefinition.new()
    d.id = id; d.display_name = title; d.tier = tier; d.base_hp = hp; d.base_damage = dmg
    d.attack_interval = interval; d.armor = armor; d.move_speed = speed; d.trap_detect_chance = detect
    d.base_gold_reward = gold; d.base_soul_reward = souls; d.ability_id = ability
    heroes[id] = d

func _add_monster(id: StringName, title: String, hp: float, dmg: float, interval: float, armor: float, speed: float, tags: Array[StringName], ability: StringName) -> void:
    var d := MonsterDefinition.new()
    d.id = id; d.display_name = title; d.base_hp = hp; d.base_damage = dmg; d.attack_interval = interval
    d.armor = armor; d.move_speed = speed; d.tags = tags; d.ability_id = ability
    monsters[id] = d

func _add_room(id: StringName, title: String, size: Vector2i, gold: float, souls: float, max_level: int, type: StringName, monster_id: StringName = &"", fame_per_second: float = 0.0, lure_value: float = 0.0) -> void:
    var d := RoomDefinition.new()
    d.id = id; d.display_name = title; d.size_cells = size; d.base_gold_cost = gold; d.base_soul_cost = souls
    d.max_level = max_level; d.room_type = type; d.spawned_monster_id = monster_id; d.base_fame_per_second = fame_per_second; d.lure_value = lure_value
    rooms[id] = d
