extends Node2D
@export var i_name : String
@export_multiline var tooltip : String
@export var icon : Texture

@export var increased_speed : int

var second_tooltip

func _ready():
	second_tooltip = "Enemy speed increased by " + str(increased_speed) + "%."

