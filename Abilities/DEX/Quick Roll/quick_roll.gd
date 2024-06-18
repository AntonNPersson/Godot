extends ability
var once = false

func _reduce_cooldown():
	unit.get_node('InventoryManager')._reduce_cooldown(self, 1)

func _advanced_update():
	if not once:
		unit.get_node('Control').basic_attacking.connect(_reduce_cooldown)
		once = true

func _use():
	super._use()
	var tag = ['Damage']
	var value = [0]
	unit.get_node('Control').on_action.emit(values[0], value, unit, tags[0], tag)