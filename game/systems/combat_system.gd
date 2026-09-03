class_name CombatSystem
extends Node

var heroes_root: Node2D
var monsters_root: Node2D
var economy: EconomySystem
var rng := RandomNumberGenerator.new()
var monster_hit_counts: Dictionary = {}

func setup(hero_root: Node2D, monster_root: Node2D, eco: EconomySystem) -> void:
    heroes_root = hero_root
    monsters_root = monster_root
    economy = eco
    rng.randomize()

func _physics_process(_delta: float) -> void:
    if heroes_root == null or monsters_root == null:
        return
    var heroes := heroes_root.get_children()
    var monsters := monsters_root.get_children()
    _monster_attacks(monsters, heroes)
    _hero_attacks(heroes, monsters)
    _cleric_heals(heroes)

func _monster_attacks(monsters: Array[Node], heroes: Array[Node]) -> void:
    for m in monsters:
        if not (m is Monster) or m.dead or m.attack_cooldown > 0.0:
            continue
        var range := 220.0 if m.definition.ability_id == &"dark_bolt" else 72.0
        var target := _nearest(m, heroes, range)
        if target == null:
            continue
        var raw := m.damage
        if m.definition.ability_id == &"pack_instinct":
            raw *= _goblin_pack_multiplier(m, monsters)
        var magic := m.definition.ability_id == &"dark_bolt"
        if _hero_blocks(target, magic):
            m.attack_cooldown = m.attack_interval
            continue
        var dealt := target.apply_damage(raw, magic)
        _after_monster_hit(m, target, dealt, heroes)
        m.attack_cooldown = m.attack_interval

func _hero_attacks(heroes: Array[Node], monsters: Array[Node]) -> void:
    for h in heroes:
        if not (h is Hero) or h.dead or h.attack_cooldown > 0.0:
            continue
        var target := _nearest(h, monsters, h.attack_range())
        if target == null:
            continue
        var hero_magic := h.definition.id == &"hero.mage"
        if target is Monster and target.definition.ability_id == &"evasion" and not hero_magic and rng.randf() < 0.20:
            h.attack_cooldown = h.attack_interval
            continue
        var raw := h.damage
        if h.definition.id == &"hero.barbarian" and h.hp / h.max_hp < 0.40:
            raw *= 1.30
        if h.definition.id == &"hero.paladin" and target is Monster and target.has_tag(&"undead"):
            raw *= 1.50
        var magic := hero_magic
        h.attack_counter += 1
        target.apply_damage(raw, magic)
        if h.definition.id == &"hero.mage" and h.attack_counter % 4 == 0:
            _mage_splash(h, target, monsters, raw * 0.45)
        h.attack_cooldown = h.attack_interval

func _after_monster_hit(monster: Monster, target: Hero, dealt: float, heroes: Array[Node]) -> void:
    var key := monster.get_instance_id()
    monster_hit_counts[key] = int(monster_hit_counts.get(key, 0)) + 1
    match monster.definition.ability_id:
        &"web":
            if int(monster_hit_counts[key]) % 3 == 0:
                target.apply_slow(0.75, 3.0)
        &"corrosion":
            target.apply_armor_debuff(max(0.70, target.armor_multiplier - 0.10), 4.0)
        &"lifesteal":
            monster.heal(dealt * 0.20)
        &"cleave":
            var hits := 0
            for other in heroes:
                if other == target or not (other is Hero) or other.dead:
                    continue
                if monster.global_position.distance_to(other.global_position) <= 80.0:
                    other.apply_damage(monster.damage * 0.50)
                    hits += 1
                    if hits >= 2:
                        break

func _cleric_heals(heroes: Array[Node]) -> void:
    for child in heroes:
        if not (child is Hero) or child.dead or child.definition.id != &"hero.cleric":
            continue
        var cleric := child as Hero
        if cleric.support_timer < 4.0:
            continue
        cleric.support_timer = 0.0
        var target: Hero = null
        var lowest := 2.0
        for other in heroes:
            if other is Hero and not other.dead:
                var pct := other.hp / max(1.0, other.max_hp)
                if pct < lowest and cleric.global_position.distance_to(other.global_position) <= 220.0:
                    target = other
                    lowest = pct
        if target:
            target.heal(20.0)

func _goblin_pack_multiplier(source: Monster, monsters: Array[Node]) -> float:
    var allies := 0
    for other in monsters:
        if other == source or not (other is Monster) or other.dead:
            continue
        if other.definition.id == &"monster.goblin" and other.source_room_id == source.source_room_id:
            allies += 1
    return 1.0 + min(0.25, 0.05 * allies)

func _hero_blocks(hero: Hero, magic: bool) -> bool:
    if magic:
        return false
    if hero.definition.id == &"hero.warrior" and rng.randf() < 0.10:
        return true
    return false

func _mage_splash(caster: Hero, primary: Combatant, monsters: Array[Node], raw: float) -> void:
    for other in monsters:
        if other == primary or not (other is Monster) or other.dead:
            continue
        if primary.global_position.distance_to(other.global_position) <= 72.0:
            other.apply_damage(raw, true)

func _nearest(source: Node2D, candidates: Array[Node], max_distance: float) -> Combatant:
    var best: Combatant = null
    var best_d := max_distance
    for c in candidates:
        if c is Combatant and not c.dead:
            var d := source.global_position.distance_to(c.global_position)
            if d < best_d:
                best_d = d
                best = c
    return best
