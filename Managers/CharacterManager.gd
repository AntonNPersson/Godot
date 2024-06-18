extends Node

signal start_round_manager()
signal character_selected(unit)
@export var units : Node

func _ready():
	var selected_character_name = GameManager.selected_character_name
	
	# Find the corresponding node based on the name
	var selected_character_scene = load("res://Units/Instance/Characters/"+ selected_character_name +".tscn")
	var selected_character = selected_character_scene.instantiate()
	units.add_child(selected_character)
	
	if selected_character:
		start_round_manager.emit()
		character_selected.emit(selected_character)
		selected_character.visible = true
