extends Node2D
@export var i_name : String
@export_multiline var tooltip : String
@export var icon : Texture

@export var increased_amount : int

var ascension_currency_multiplier = 0.6

var second_tooltip

func _ready():
	second_tooltip = "Enemy amount increased by " + str(increased_amount) + "%."

