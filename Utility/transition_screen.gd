extends Sprite2D
# Called when the node enters the scene tree for the first time.
func _ready():
	self.modulate.a = 0
	
func _start(time):
	get_child(0).play('transition', 1/time)

	
func _on_round_manager_transition(time):
	_start(time)
