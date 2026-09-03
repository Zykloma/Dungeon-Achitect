class_name RoomDefinition
extends Resource

@export var id: StringName
@export var display_name: String
@export var size_cells: Vector2i = Vector2i.ONE
@export var base_gold_cost: float
@export var base_soul_cost: float
@export var max_level: int = 10
@export var room_type: StringName
@export var spawned_monster_id: StringName
@export var base_fame_per_second: float
@export var lure_value: float
