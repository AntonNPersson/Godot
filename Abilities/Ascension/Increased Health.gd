extends Node2D
@export var i_name : String
@export_multiline var tooltip : String
@export var icon : Texture

@export var increased_health : int

@export var ascension_currency_multiplier = 0.2
var second_tooltip

func _ready():
	second_tooltip = "Enemy health increased by " + str(increased_health) + "%."

