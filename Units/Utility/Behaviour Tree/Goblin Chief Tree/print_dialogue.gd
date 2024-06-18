extends Task
class_name has_printed_dialogue
@export var test = ["You makin' me angry, noone likes me when i'm angry!"]

func _run(_delta):
	Utility.get_node('Dialogue')._create_dialogue(test, 2)
	Utility.get_node("Dialogue").typing_finished.connect(_unpause)
	GameManager._pause_game()
	_success()
		
func _child_success():
	_success()

func _child_fail():
	_fail()

func _unpause():
	GameManager._continue_game()
