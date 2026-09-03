class_name GridService
extends Node

const CELL_SIZE := 64
const FLOOR_SIZE := Vector2i(48, 36)

var walkable: Dictionary = {}
var occupied: Dictionary = {}
var room_cells: Dictionary = {}

func cell_to_world(cell: Vector2i) -> Vector2:
    return Vector2(cell.x * CELL_SIZE + CELL_SIZE * 0.5, cell.y * CELL_SIZE + CELL_SIZE * 0.5)

func world_to_cell(world: Vector2) -> Vector2i:
    return Vector2i(floori(world.x / CELL_SIZE), floori(world.y / CELL_SIZE))

func in_bounds(cell: Vector2i) -> bool:
    return cell.x >= 0 and cell.y >= 0 and cell.x < FLOOR_SIZE.x and cell.y < FLOOR_SIZE.y

func rect_cells(origin: Vector2i, size: Vector2i) -> Array[Vector2i]:
    var result: Array[Vector2i] = []
    for y in range(size.y):
        for x in range(size.x):
            result.append(origin + Vector2i(x, y))
    return result

func can_place(origin: Vector2i, size: Vector2i, allow_overlap_walkable := false) -> bool:
    for cell in rect_cells(origin, size):
        if not in_bounds(cell):
            return false
        if occupied.has(cell):
            return false
        if not allow_overlap_walkable and walkable.has(cell):
            return false
    return true

func occupy(room_id: int, origin: Vector2i, size: Vector2i, is_walkable := true) -> void:
    var cells := rect_cells(origin, size)
    room_cells[room_id] = cells
    for cell in cells:
        occupied[cell] = room_id
        if is_walkable:
            walkable[cell] = true

func add_corridor(cell: Vector2i, room_id: int) -> void:
    if not in_bounds(cell): return
    occupied[cell] = room_id
    walkable[cell] = true
    room_cells[room_id] = [cell]

func is_walkable(cell: Vector2i) -> bool:
    return walkable.has(cell)

func has_adjacent_walkable(origin: Vector2i, size: Vector2i) -> bool:
    for cell in rect_cells(origin, size):
        for dir in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
            if walkable.has(cell + dir):
                return true
    return false

func serialize() -> Dictionary:
    var rows: Array = []
    for room_id in room_cells:
        var encoded: Array = []
        for c: Vector2i in room_cells[room_id]: encoded.append([c.x, c.y])
        rows.append({"id": room_id, "cells": encoded})
    return {"rooms": rows}
