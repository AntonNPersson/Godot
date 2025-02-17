extends PotionBase

func _initialize():
	i_name = "Mana Potion"
	type = "Mana"
	heal = 60
	charges = 2
	tooltip = "Heal 15% " + str(heal) + " mana. Has " + str(charges) + " charges, and a chance to drop a charge on enemy death."
	icon = preload('res://Sprites/Icons/Weak_Mana_Potion.png')

func _use():
	if player.current_mana >= player.total_mana:
		Utility.get_node("ErrorMessage")._create_error_message("Mana already full", self)
	player.current_mana += heal + (player.total_mana * 0.15)
	if player.current_mana > player.total_mana:
		player.current_mana = player.total_mana
