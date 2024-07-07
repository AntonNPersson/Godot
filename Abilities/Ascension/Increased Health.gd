extends Node2D
@export var i_name : String
@export_multiline var tooltip : String
@export var icon : Texture

@export var increased_health : int
var second_tooltip

func _ready():
	second_tooltip = "Enemy health increased by " + str(increased_health) + "%."

