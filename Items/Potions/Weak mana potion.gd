extends Node2D
var tooltip
var i_name = "Weak Mana Potion"
var type = "Mana"
var heal = 30
var charges = 2
var player
var icon = preload('res://Sprites/Icons/Weak_Mana_Potion.png')

func _initialize():
	heal = 30
	tooltip = "Heal 15% " + str(heal) + " mana. Has " + str(charges) + " charges, and a chance to drop a charge on enemy death."

func _use():
	player.current_mana += heal + (player.total_mana * 0.15)
	if player.current_mana > player.total_mana:
		player.current_mana = player.total_mana
