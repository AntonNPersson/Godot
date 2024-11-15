extends Node2D
var first_texture
var popup_menu
var characters
var character_list
var info
# Called when the node enters the scene tree for the first time.
func _ready():
	first_texture = preload("res://Sprites/character_select_background.jpg")
	_on_next_typing()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_next_typing():
		get_node("UI/Sprite2D").texture = first_texture
		popup_menu = get_child(0).get_child(1)
		characters = preload("res://Units/Instance/characters.tscn")
		var character_instance = characters.instantiate()
		character_list = character_instance.get_children()
		info = get_node("UI/Info")
		add_child(character_instance)
		for character in character_instance.get_children():
			popup_menu.add_item(character.name)
	
func _on_finished():
	Utility.get_node('Transition')._start(2)
	await get_tree().create_timer(0.5).timeout
	GameManager._change_scene("res://Scenes/Game.tscn", true)
	
func _on_item_list_item_clicked(index, _at_position, _mouse_button_index):
	info.get_node('Types').text = "[center]"
	GameManager.selected_character_name = popup_menu.get_item_text(index)
	info.get_node('Name').text = "[center]" + str(character_list[index].name)
	info.get_node('Border').get_node('Icon').texture = character_list[index].icon
	info.get_node('Passive_name').text = "[center]" + str(character_list[index].passive_name)
	info.get_node('Passive_tooltip').text = "[center]" + str(character_list[index].passive_tooltip)
	info.get_node('Active_name').text = "[center]" + str(character_list[index].active_name)
	info.get_node('Active_tooltip').text = "[center]" + str(character_list[index].active_tooltip)
	for i in range(character_list[index].type.size()):
		if i == character_list[index].type.size() - 1:
			info.get_node('Types').text += str(character_list[index].type[i])
			break
		info.get_node('Types').text += str(character_list[index].type[i]) + ", "
	info.visible = true
	


