extends Node
@export var dialogue_scene : PackedScene
var dialogue_instance
signal next_typing()
signal typing_finished()

func _create_dialogue(dialogue : Array, time):
	dialogue_instance = dialogue_scene.instantiate()
	self.add_child(dialogue_instance)
	dialogue_instance.get_child(0).get_child(0)._start_typing(dialogue, time)
	dialogue_instance.get_child(0).get_child(0).typing_finished.connect(_on_typing_finished)
	dialogue_instance.get_child(0).get_child(0).next_typing.connect(_on_next_typing)

func _create_dialogue_on_unit(dialogue : Array, time, unit):
	dialogue_instance = dialogue_scene.instantiate()
	self.add_child(dialogue_instance)
	dialogue_instance.get_child(0).get_child(2).visible = true
	dialogue_instance.get_child(0).get_child(2).texture = unit.get_node('AnimatedSprite2D').get_sprite_frames().get_frame_texture('Walk East', 0)
	dialogue_instance.get_child(0).get_child(0)._start_typing(dialogue, time)
	dialogue_instance.get_child(0).get_child(0).typing_finished.connect(_on_typing_finished)
	dialogue_instance.get_child(0).get_child(0).next_typing.connect(_on_next_typing)
	
func _on_typing_finished():
	typing_finished.emit()
	dialogue_instance.queue_free()
	dialogue_instance.get_child(0).get_child(2).visible = false
	
func _on_next_typing():
	next_typing.emit()
