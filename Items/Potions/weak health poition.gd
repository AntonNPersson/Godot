extends Node2D
var tooltip
var i_name = "Weak Healing Potion"
var type = "Health"
var heal = 30
var charges = 2
var player

func _initialize():
	heal = 30
	tooltip = "Heal 15% " + str(heal) + " health. Has " + str(charges) + " charges, and a chance to drop a charge on enemy death."

func _use():
	player.current_health += heal + (player.total_health * 0.15)
	if player.current_health > player.total_health:
		player.current_health = player.total_health
