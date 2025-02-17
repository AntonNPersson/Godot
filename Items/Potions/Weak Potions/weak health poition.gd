extends PotionBase

func _initialize():
	i_name = "Weak Health Potion"
	type = "Health"
	heal = 30
	charges = 2
	tooltip = "Heal 15% " + str(heal) + " health. Has " + str(charges) + " charges, and a chance to drop a charge on enemy death."
	icon = preload('res://Sprites/Icons/Weak_Health_Potion.png')

func _use():
	if player.current_health >= player.total_health:
		Utility.get_node("ErrorMessage")._create_error_message("Health already full", self)
	player.current_health += heal + (player.total_health * 0.15)
	if player.current_health > player.total_health:
		player.current_health = player.total_health
