extends Node

func _update_health(percentage):
	self.visible = true
	self.value = percentage
	if percentage <= 0:
		self.visible = false
		
func _update_stamina(percentage):
	self.visible = true
	self.value = percentage

func _update_mana(percentage):
	self.visible = true
	self.value = percentage
	
func _update_barrier(percentage):
	self.visible = true
	self.value = percentage

func _update_potion(total_charge, current_charge, type):
	self.visible = true

	if type == "Health":
		if current_charge == 0:
			self.texture = load("res://GUI/potions0 x2.png")
		if current_charge == total_charge/2:
			self.texture = load("res://GUI/potions2 x2.png")
		if current_charge == total_charge:
			self.texture = load("res://GUI/potions1 x2.png")
	elif type == "Stamina":
		if current_charge == 0:
			self.texture = load("res://GUI/potions0 x2.png")
		if current_charge == total_charge/2:
			self.texture = load("res://GUI/stamina_potion_1.png")
		if current_charge == total_charge:
			self.texture = load("res://GUI/stamina_potion_2.png")
	elif type == "Mana":
		if current_charge == 0:
			self.texture = load("res://GUI/potions0 x2.png")
		if current_charge == total_charge/2:
			self.texture = load("res://GUI/mana_potion_1.png")
		if current_charge == total_charge:
			self.texture = load("res://GUI/mana_potion_2.png")
	elif type == "Barrier":
		if current_charge == 0:
			self.texture = load("res://GUI/potions0 x2.png")
		if current_charge == total_charge/2:
			self.texture = load("res://GUI/barrier_potion_1.png")
		if current_charge == total_charge:
			self.texture = load("res://GUI/barrier_potion_2.png")

func _update_name(_name):
	self.get_parent().get_node('Label').text = _name
