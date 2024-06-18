extends Node2D
@export var wall : PackedScene
@export var _floor : PackedScene
@export var spawn : PackedScene
@export var player_spawn : PackedScene
@export var torch : PackedScene
@export var boss_spawn : PackedScene
var array : Array

func _get_array():
	array.append(_floor)
	array.append(wall)
	array.append(player_spawn)
	array.append(spawn)
	array.append(boss_spawn)
	array.append(torch)
	return array
