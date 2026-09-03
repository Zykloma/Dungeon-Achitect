class_name CombatSystem
extends Node

var heroes_root: Node2D
var monsters_root: Node2D
var economy: EconomySystem

func setup(hero_root: Node2D, monster_root: Node2D, eco: EconomySystem) -> void:
    heroes_root = hero_root; monsters_root = monster_root; economy = eco

func _physics_process(_delta: float) -> void:
    if heroes_root == null or monsters_root == null: return
    var heroes := heroes_root.get_children()
    var monsters := monsters_root.get_children()
    for m in monsters:
        if not (m is Monster) or m.dead or m.attack_cooldown > 0.0: continue
        var target := _nearest(m, heroes, 72.0)
        if target:
            target.apply_damage(m.damage); m.attack_cooldown = m.attack_interval
    for h in heroes:
        if not (h is Hero) or h.dead or h.attack_cooldown > 0.0: continue
        var target := _nearest(h, monsters, 58.0)
        if target:
            target.apply_damage(h.damage); h.attack_cooldown = h.attack_interval

func _nearest(source: Node2D, candidates: Array[Node], max_distance: float) -> Combatant:
    var best: Combatant = null
    var best_d := max_distance
    for c in candidates:
        if c is Combatant and not c.dead:
            var d := source.global_position.distance_to(c.global_position)
            if d < best_d: best_d = d; best = c
    return best
