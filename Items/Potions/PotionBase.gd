extends Node2D
class_name PotionBase
var tooltip
var i_name
var type
var heal
var charges
var player
var icon
var rarity

func _initialize():
	pass

func _use():
	pass

func _ascend(power):
	set("heal", heal * power)
