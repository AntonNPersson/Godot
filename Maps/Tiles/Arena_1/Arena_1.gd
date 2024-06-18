extends Node2D
@export var wall : PackedScene
@export var teleporter : PackedScene
@export var _floor : PackedScene
@export var torch : PackedScene
@export var spawn : PackedScene
@export var north_wall : PackedScene
@export var boulder : PackedScene
@export var player_spawn : PackedScene
@export var boss_spawn : PackedScene
@export var boss_encounter : PackedScene
@export var left_wall : PackedScene
@export var right_wall : PackedScene
@export var south_wall : PackedScene
@export var top_left : PackedScene
@export var top_right : PackedScene
@export var bottom_left : PackedScene
@export var bottom_right : PackedScene
var array : Array[PackedScene]


func _get_array():
	array.append(_floor)
	array.append(wall)
	array.append(player_spawn)
	array.append(spawn)
	array.append(boss_spawn)
	array.append(boss_encounter)
	array.append(torch)
	array.append(north_wall)
	array.append(boulder)
	array.append(teleporter)
	array.append(left_wall)
	array.append(right_wall)
	array.append(south_wall)
	array.append(top_left)
	array.append(top_right)
	array.append(bottom_left)
	array.append(bottom_right)
	return array
