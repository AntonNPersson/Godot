extends Node2D
var unit
@export var tooltip = ""
@export var teleport_distance = 150
@export var cost = 30
@export var particle_effects : CPUParticles2D
@export var icon : Texture
var current_cooldown = 0

func _use_ability(_delta):
	current_cooldown -= _delta
	if Input.is_action_just_pressed('Dash'):
		if unit.current_stamina - cost < 0:
			Utility.get_node("ErrorMessage")._create_error_message("Not enough stamina!", unit)
			return
		
		if !unit.map_manager._is_tile_walkable(unit.map_manager._world_to_tilemap_position_all(get_global_mouse_position())):
			Utility.get_node("ErrorMessage")._create_error_message("Invalid teleport location!", unit)
			return
		start_dash()
			


func start_dash():
	get_child(0).global_position = unit.global_position
	get_child(0).play()
	var teleport_direction = (get_global_mouse_position() - unit.global_position).normalized()
	var teleport_position = unit.global_position + teleport_direction * teleport_distance
	unit.global_position = teleport_position
	unit.current_stamina -= cost



