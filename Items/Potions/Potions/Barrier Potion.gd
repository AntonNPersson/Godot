extends PotionBase

func _initialize():
	i_name = "Barrier Potion"
	type = "Barrier"
	charges = 2
	heal = 60
	tooltip = "Heal 15% " + str(heal) + " barrier. Has " + str(charges) + " charges, and a chance to drop a charge on enemy death."
	icon = preload('res://Sprites/Icons/Weak_barrier_Potion.png')

func _use():
	if player.current_barrier >= player.total_barrier:
		Utility.get_node("ErrorMessage")._create_error_message("Barrier already full", self)
	player.current_barrier += heal + (player.total_barrier * 0.15)
	if player.current_barrier > player.total_barrier:
		player.current_barrier = player.total_barrier
