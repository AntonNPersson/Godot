extends player_variables
# Private Variables
@export var level_up_menu : PackedScene
@export var passive_name : String
@export var passive_tooltip : String
@export var passive_increase : int
# Private Methods
func _level_up():
	var instance = level_up_menu.instantiate()
	instance.get_child(0).item_selected.connect(_on_finished)
	instance.name = 'menu'
	add_child(instance)
	
func _on_finished(index):
	if index == 0:
		bonus_dexterity += passive_increase
	elif index == 1:
		bonus_strength += passive_increase
	elif index == 2:
		bonus_intelligence += passive_increase
		_update_stats()
	_update_stats()
	get_node('menu').queue_free()
