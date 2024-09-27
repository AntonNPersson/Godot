extends Node

signal start_round_manager()
signal character_selected(unit)
@export var units : Node
@export var item_manager : Node
var selected_character_name : String

func _initialize():
	print('Character Manager Initialized')
	if selected_character_name.is_empty():
		selected_character_name = GameManager.selected_character_name
	
	# Find the corresponding node based on the name
	var selected_character_scene = load("res://Units/Instance/Characters/"+ selected_character_name + "/"+ selected_character_name +".tscn")
	var selected_character = selected_character_scene.instantiate()
	units.add_child(selected_character)
	selected_character.item_manager = item_manager
	
	if selected_character:
		character_selected.emit(selected_character)
		selected_character.visible = true
	return selected_character

func save():
	var save_dict = {
		"filename" : get_path(),
		"parent" : get_parent().get_name(),
		"selected_character_name": selected_character_name
	}
	print(save_dict)
	return save_dict
