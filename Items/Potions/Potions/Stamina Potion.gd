extends PotionBase

func _initialize():
	i_name = "Stamina Potion"
	type = "Stamina"
	heal = 25
	charges = 2
	tooltip = "Heal 15% " + str(heal) + " stamina. Has " + str(charges) + " charges, and a chance to drop a charge on enemy death."
	icon = preload('res://Sprites/Icons/Weak_stamina_Potion.png')

func _use():
	if player.current_stamina >= player.total_stamina:
		Utility.get_node("ErrorMessage")._create_error_message("Stamina already full", self)
	player.current_stamina += heal + (player.total_stamina * 0.15)
	if player.current_stamina > player.total_stamina:
		player.current_stamina = player.total_stamina
