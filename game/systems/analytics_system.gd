class_name AnalyticsSystem
extends Node

var room_kills: Dictionary = {}
var cell_deaths: Dictionary = {}
var trap_hits: Dictionary = {}
var trap_damage: Dictionary = {}

func record_kill(room_id: int, cell: Vector2i) -> void:
    room_kills[room_id] = int(room_kills.get(room_id, 0)) + 1
    cell_deaths[cell] = int(cell_deaths.get(cell, 0)) + 1

func record_trap_hit(room_id: int, cell: Vector2i, damage: float) -> void:
    trap_hits[room_id] = int(trap_hits.get(room_id, 0)) + 1
    trap_damage[room_id] = float(trap_damage.get(room_id, 0.0)) + damage

func reset_run() -> void:
    room_kills.clear()
    cell_deaths.clear()
    trap_hits.clear()
    trap_damage.clear()

func serialize() -> Dictionary:
    return {
        "room_kills": room_kills.duplicate(true),
        "trap_hits": trap_hits.duplicate(true),
        "trap_damage": trap_damage.duplicate(true),
    }

func restore(data: Dictionary) -> void:
    room_kills = data.get("room_kills", {}).duplicate(true)
    trap_hits = data.get("trap_hits", {}).duplicate(true)
    trap_damage = data.get("trap_damage", {}).duplicate(true)
