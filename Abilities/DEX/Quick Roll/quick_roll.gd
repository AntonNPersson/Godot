extends ability
var once = false

func _reduce_cooldown(target):
	target = self
	unit.get_node('InventoryManager')._reduce_cooldown(target, 1)

func _advanced_update():
	if not once:
		unit.get_node('Control').basic_attacking.connect(_reduce_cooldown)
		once = true