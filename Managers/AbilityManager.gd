extends Node
signal picked(ability_)
var popUp
var ability_popup
var button

var int_scene
var dex_Scene
var str_Scene
var int_list
var dex_List
var str_List
var int_instance
var dex_Instance
var str_Instance

var current_ability_choices
var chosen_ability_choices = []
var selected_ability
var current_ability_round = 0
var chosen_abilities = []
var reroll_amount = 99

var target
# Called when the node enters the scene tree for the first time.
func _ready():
	int_scene = preload("res://Abilities/int.tscn")
	dex_Scene = preload("res://Abilities/dex.tscn")
	str_Scene =  preload("res://Abilities/str.tscn")
	int_instance = int_scene.instantiate()
	dex_Instance = dex_Scene.instantiate()
	str_Instance = str_Scene.instantiate()
	add_child(int_instance)
	add_child(dex_Instance)
	add_child(str_Instance)
	int_list = int_instance.get_children()
	dex_List = dex_Instance.get_children()
	str_List = str_Instance.get_children()
	popUp = get_node('UI/CanvasLayer/choiceList')
	button = get_node("UI/CanvasLayer/showButton")
	ability_popup = get_node('UI/CanvasLayer/Panel')

func _process(delta):
	get_node("UI/CanvasLayer/Panel/Reroll_amount").text = str(reroll_amount) + "x"

func _choose_ability_choices(list):
	var choices = []
	randomize()
	for i in range(3):
		choices.append(list.pick_random())
	if len(choices) < 3 or choices[0] == choices[1] or choices[0] == choices[2] or choices[1] == choices[2] or choices[0] in chosen_abilities or choices[1] in chosen_abilities or choices[2] in chosen_abilities:
		_choose_ability_choices(list)
	else:
		current_ability_choices = choices
		return choices

func _show_ability_choices():
	ability_popup.get_node('Choice_1').get_node('Name').text = current_ability_choices[0].name
	ability_popup.get_node('Choice_2').get_node('Name').text = current_ability_choices[1].name
	ability_popup.get_node('Choice_3').get_node('Name').text = current_ability_choices[2].name

	ability_popup.get_node('Choice_1').get_node('Icon').texture = current_ability_choices[0].icon
	ability_popup.get_node('Choice_2').get_node('Icon').texture = current_ability_choices[1].icon
	ability_popup.get_node('Choice_3').get_node('Icon').texture = current_ability_choices[2].icon

	for i in current_ability_choices:
		i._update_tooltip()

	ability_popup.get_node('Choice_1').get_node('Tooltip').text = current_ability_choices[0].tooltip
	ability_popup.get_node('Choice_2').get_node('Tooltip').text = current_ability_choices[1].tooltip
	ability_popup.get_node('Choice_3').get_node('Tooltip').text = current_ability_choices[2].tooltip
	ability_popup.visible = true

func _on_next_choice(unit):
	current_ability_round += 1
	var ability_list = []
	target = unit
	if current_ability_round <= 4:
		if unit.type.has("INT"):
			ability_list.append_array(int_list)
		if unit.type.has("DEX"):
			ability_list.append_array(dex_List)
		if unit.type.has("STR"):
			ability_list.append_array(str_List)
		_choose_ability_choices(ability_list)
		_show_ability_choices()
	
func _on_choice_list_item_clicked(index_, _at_position, _mouse_button_index_):
		if index_ == popUp.item_count -1:
			popUp.visible = false
			button.visible = true
		else:
			selected_ability = current_ability_choices[index_ -1]
			chosen_abilities.append(selected_ability)
			picked.emit(selected_ability)
			popUp.visible = false

func _on_button_pressed():
	popUp.visible = true
	button.visible = false	

func _on_character_selected(unit):
	picked.connect(unit.get_node("InventoryManager")._on_ability_manager_picked)


func _on_select_1_pressed():
	picked.emit(current_ability_choices[0])
	chosen_ability_choices.append(current_ability_choices[0])
	ability_popup.visible = false


func _on_select_2_pressed():
	picked.emit(current_ability_choices[1])
	chosen_ability_choices.append(current_ability_choices[1])
	ability_popup.visible = false


func _on_select_3_pressed():
	picked.emit(current_ability_choices[2])
	chosen_ability_choices.append(current_ability_choices[2])
	ability_popup.visible = false


func _on_reroll_pressed():
	if reroll_amount > 0:
		reroll_amount -= 1
		var ability_list = []
		if target.type.has("INT"):
			ability_list = int_list
		if target.type.has("DEX"):
			ability_list = dex_List
		if target.type.has("STR"):
			ability_list = str_List
		_choose_ability_choices(ability_list)
		_show_ability_choices()
	else:
		Utility.get_node("ErrorMessage")._create_error_message("You have no rerolls left", target)
