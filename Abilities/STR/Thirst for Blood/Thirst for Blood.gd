extends ability
var start_cooldown

func _advanced_update():
	if target == null:
		return
	if target.has_node('Bleed_timer'):
		cooldown = start_cooldown/2
	else:
		cooldown = start_cooldown

func _ready():
	start_cooldown = cooldown
