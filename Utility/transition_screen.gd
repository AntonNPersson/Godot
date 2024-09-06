extends Sprite2D
# Called when the node enters the scene tree for the first time.
func _ready():
	self.modulate.a = 0
	
func _start(time):
	get_child(0).play('transition', 1/time)

func _start_death(time, ascension_currency, ascension_level):
	get_parent().get_node('Ascension Currency').text = "[center]Ascension Currency: " + str(ascension_currency) + "[/center]"
	get_parent().get_node('Ascension Level').text = "[center]Ascension Level: " + str(ascension_level) + "[/center]"
	get_child(0).play('death', 1/time)

func _on_round_manager_transition(time):
	_start(time)

func _on_button_pressed():
	GameManager._change_scene("res://Scenes/Menu.tscn", true)
	Utility.get_node("Transition").get_child(0).play("RESET")
