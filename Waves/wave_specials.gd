extends Node
class_name Wave
@export_multiline var tooltip : String
@export var grade : String

func _get_special():
	pass

func _get_tooltip():
	tooltip += "\nGrade: " + grade
	return tooltip
