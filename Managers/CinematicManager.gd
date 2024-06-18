extends Node
@export var boss_encounter_text : PackedScene

func _start_cinematic(camera : Camera2D, target : Vector2, duration : float, _name : String):
	GameManager._pause_game()
	
	var tween = get_tree().create_tween()
	tween.tween_property(camera, "global_position", target, duration)
	tween.connect("finished", _on_tween_completed.bind(_name))

func _on_tween_completed(_name):
	var boss_encounter_instance = boss_encounter_text.instantiate()
	boss_encounter_instance.get_child(0).text = _name
	add_child(boss_encounter_instance)
	await get_tree().create_timer(2).timeout
	boss_encounter_instance.queue_free()
	GameManager._continue_game()


