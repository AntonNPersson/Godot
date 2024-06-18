extends Node
func _ready():
	self.modulate = Color(0,1,0)

func _update_health(percentage):
	self.visible = true
	self.value = percentage
	if not self.get_parent().is_in_group('UI'):
		self.get_parent().global_rotation = 0
	if percentage <= 0:
		self.visible = false
	elif percentage < 30:
		self.modulate = Color.CRIMSON
	elif percentage < 70:
		self.modulate = Color.ORANGE
	else:
		self.modulate = Color.WEB_GREEN
		
func _update_stamina(percentage):
	self.modulate = Color.YELLOW
	self.visible = true
	self.value = percentage

func _update_mana(percentage):
	self.modulate = Color.BLUE
	self.visible = true
	self.value = percentage
	
func _update_barrier(percentage):
	self.modulate = Color.LIGHT_CYAN
	self.modulate.a = 0.5
	self.visible = true
	self.value = percentage

func _update_potion(total_charge, current_charge, type):
	self.value = current_charge
	self.max_value = total_charge
	self.visible = true

	if type == "Health":
		self.modulate = Color.CRIMSON
	elif type == "Stamina":
		self.modulate = Color.YELLOW
	elif type == "Mana":
		self.modulate = Color.BLUE
	elif type == "Barrier":
		self.modulate = Color.LIGHT_CYAN
		self.modulate.a = 0.5

func _update_name(_name):
	self.get_parent().get_node('Label').text = _name
