extends Node

var state
var state_factory
var ability_cooldowns = []
var ability_cast_duration = []
var ranges = []
var timers = []

# Called when the node enters the scene tree for the first time.
func _ready():
	state_factory = StateFactory.new()
	get_parent().add_child.call_deferred(state_factory)
	_change_state("chasing")
	for ability_ in range(get_parent().abilities.size()):
		var pre = get_parent().abilities[ability_].instantiate()
		ability_cooldowns.append(pre.cooldown)
		ability_cast_duration.append(pre.cast_duration)
		var timer
		if "always_active" in pre:
			timer = 0
			print("always active")
		else:
			timer = pre.cooldown
		timers.append(timer)
		ranges.append(pre._range)
		pre.queue_free()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	state._update(delta)
	if !get_parent().dead and !get_parent().paused:
		state._action(delta)
	
func _change_state(new_state):
	if state != null:
		state.queue_free()
	state = state_factory.get_state(new_state).new()
	state._setup(Callable(self, "_change_state"), self.get_parent(), ability_cooldowns, ability_cast_duration, ranges, timers)
	add_child(state)
