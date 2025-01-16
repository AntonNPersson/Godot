extends Node2D
var first_texture
var popup_menu
var characters
var character_list
var info
var selected_character
# Called when the node enters the scene tree for the first time.
func _ready():
	first_texture = preload("res://Sprites/character_select_background.jpg")
	_on_next_typing()

func _process(delta):
	if character_list != null:
		for cha in character_list:
			if cha.unlocked:
				if cha.name == selected_character:
					get_node("UI/" + cha.name).modulate = Color(1, 1, 1, 0.6)
				else:
					get_node("UI/" + cha.name).modulate = Color(1, 1, 1, 1)
			else:
				get_node("UI/" + cha.name).modulate = Color(0, 0, 0, 0.8)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_next_typing():
		get_node("UI/Sprite2D").texture = first_texture
		characters = preload("res://Units/Instance/characters.tscn")
		var character_instance = characters.instantiate()
		character_list = character_instance.get_children()
		print(character_list)
		info = get_node("UI/Info")
		add_child(character_instance)
	
func _on_finished():
	Utility.get_node('Transition')._start(2)
	await get_tree().create_timer(0.5).timeout
	GameManager.new_game()
	
func _on_character_pressed(event:InputEvent, extra_arg_0:String):
	if event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed:
		selected_character = extra_arg_0
		var index = 0
		for cha in character_list:
			if cha.name == extra_arg_0:
				index = character_list.find(cha)
		if !character_list[index].unlocked:
			return

		info.get_node('Types').text = "[center]"
		GameManager.selected_character_name = extra_arg_0
		info.get_node('Name').text = "[center]" + str(character_list[index].name)
		info.get_node('Passive_name').text = "[center]" + str(character_list[index].passive_name)
		info.get_node('Passive_tooltip').text = "[center]" + str(character_list[index].passive_tooltip)
		info.get_node('Active_name').text = "[center]" + str(character_list[index].active_name)
		info.get_node('Active_tooltip').text = "[center]" + str(character_list[index].active_tooltip)
		for i in range(character_list[index].type.size()):
			if i == character_list[index].type.size() - 1:
				info.get_node('Types').text += str(set_type_color(character_list[index].type[i]))
				break
			info.get_node('Types').text += str(set_type_color(character_list[index].type[i])) + ", "
		info.visible = true

func set_type_color(type):
	if type == "STR":
		return "[color=Orangered]" + type + "[/color]"
	if type == "DEX":
		return "[color=Lightgreen]" + type + "[/color]"
	if type == "INT":
		return "[color=Royalblue]" + type + "[/color]"
