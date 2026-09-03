class_name UpgradeDefinition
extends Resource

@export var id: StringName
@export var display_name: String
@export var max_rank: int = 1
@export var currency: StringName = &"gold"
@export var base_cost: float
@export var cost_growth: float = 1.0
@export var effect_per_rank: float
