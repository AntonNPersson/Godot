extends Node

var state
var state_factory

# Called when the node enters the scene tree for the first time.
func _ready():
	state_factory = StateFactory.new()
	get_parent().add_child.call_deferred(state_factory)
	_change_state("chasing")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	state._update(delta)
	if !get_parent().dead and !get_parent().paused:
		state._action(delta)
	
func _change_state(new_state):
	if state != null:
		state.queue_free()
	state = state_factory.get_state(new_state).new()
	state._setup(Callable(self, "_change_state"), self.get_parent())
	add_child(state)
