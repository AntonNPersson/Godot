extends Task
@export var summon = false

func _ready():
	unit = get_parent()
	target = _get_closest_target()
	print(target)
	tree = self
	animation = unit.get_node('AnimatedSprite2D')
	cast_bar = unit.get_node('UI/cast_bar')
	for ability_ in unit.abilities:
		var preloaded = ability_.instantiate()
		ability_cooldowns.append(preloaded.cooldown)
		var timer = preloaded.cooldown
		timers.append(timer)
		preloaded.queue_free()
	_start()
	_running()

func _process(delta):
	if summon:
		print('summoning')
		target = _get_closest_enemy()
		unit = get_parent()
	else:
		target = _get_closest_target()
	if cast_bar.value >= 100:
		cast_bar.visible = false
	for i in range(ability_cooldowns.size()):
		timers[i] -= 1 * delta
	if status == RUNNING:
		get_child(0)._run(delta)
	
func _child_running():
	status = RUNNING

func _child_success():
	status = SUCCEEDED
	
func _child_failed():
	status = FAILED


func _on_goblin_chief_is_dead(_unit:Variant):
	_cancel()
