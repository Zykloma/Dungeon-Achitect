class_name AnalyticsSystem
extends Node

var room_kills: Dictionary = {}
var cell_deaths: Dictionary = {}

func record_kill(room_id: int, cell: Vector2i) -> void:
    room_kills[room_id] = int(room_kills.get(room_id, 0)) + 1
    cell_deaths[cell] = int(cell_deaths.get(cell, 0)) + 1
