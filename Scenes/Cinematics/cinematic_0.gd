extends Node2D
var dialogue = ['In your mundane boredom you were looking for any game to play, searching the internet you stumbled upon some shitty game that had no reviews, but why not, you thought. Starting up the game you entered the character select.',
 "There are several characters to choose from, something is telling you this is important, almost like it would decide what character you're playing for the rest of your life. I would recommend taking your time, whoever I am."
]
var _dialogue = ['Suddenly you are feeling yourself getting sucked in. It looks like some kind of vortex. You do not know what to do, and neither do I, but there is a light in the end of the tunnel, hopefully it can help - probably not, but what do you have to lose? Then as fast as it appeared, you blacked out.']
var first_texture
var second_texture
var current_screen = 0
var popup_menu
var characters
# Called when the node enters the scene tree for the first time.
func _ready():
	first_texture = preload("res://Sprites/character_select_background.jpg")
	second_texture = preload("res://Sprites/vortex.jpg")
	Utility.get_node('Dialogue')._create_dialogue(dialogue, 3)
	Utility.get_node('Dialogue').next_typing.connect(_on_next_typing)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_next_typing():
	current_screen += 1
	Utility.get_node('Transition')._start(2)
	await get_tree().create_timer(2).timeout
	if current_screen == 1:
		get_node("UI/Sprite2D").texture = first_texture
		popup_menu = get_child(0).get_child(1)
		characters = preload("res://Units/Instance/characters.tscn")
		var character_instance = characters.instantiate()
		add_child(character_instance)
		for character in character_instance.get_children():
			popup_menu.add_item(character.name)
			popup_menu.set_item_tooltip(popup_menu.get_item_count() - 1, character.tooltip)
	
func _on_finished():
	Utility.get_node('Transition')._start(2)
	await get_tree().create_timer(2).timeout
	GameManager._change_scene("res://Scenes/Game.tscn", true)
	
func _on_item_list_item_clicked(index, _at_position, _mouse_button_index):
	GameManager.selected_character_name = popup_menu.get_item_text(index)
	popup_menu.visible = false
	Utility.get_node('Transition')._start(2)
	await get_tree().create_timer(2).timeout
	get_node("UI/Sprite2D").texture = second_texture
	Utility.get_node('Dialogue')._create_dialogue(_dialogue, 3)
	Utility.get_node('Dialogue').typing_finished.connect(_on_finished)
	
	


