extends Node
class_name Wave
@export_multiline var tooltip : String
@export var grade : String
@export var icon : Texture
@export var wave_name : String

func _get_special():
	pass

func _get_tooltip():
	tooltip += "\nGrade: " + grade
	return tooltip
