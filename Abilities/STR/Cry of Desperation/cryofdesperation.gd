extends ability
var initial_damage = 20
func _advanced_update():
	var index = values.find("Damage")
	var missing_health_percentage = (unit.total_health - unit.current_health) / unit.total_health
	values[index] = initial_damage + initial_damage * missing_health_percentage

func _level_grants():
	super._level_grants()
	initial_damage = values.find("Damage")
