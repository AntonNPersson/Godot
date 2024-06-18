extends Node
class_name StateFactory

var states : Dictionary

func _init():
	states = {
		'idle' : IdleState,
		'chasing': ChasingState,
		'attacking': AttackingState,
		'casting': CastingState
	}
# Called when the node enters the scene tree for the first time.
func get_state(state_name):
	if states.has(state_name):
		return states.get(state_name)
	else:
		printerr("No state ", state_name, " in state factory!")
