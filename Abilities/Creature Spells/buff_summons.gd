extends Node2D
var troop
var unit
@export var cast_duration = 0
@export var cooldown = 9999999
@export var health_increase = 100
@export var attack_damage_increase = 20
@export var speed_increase = 100
var current_summons = 1
# Called every frame. 'delta' is the elapsed time since the previous frame.
	
func _process(_delta):
	if is_queued_for_deletion():
		pass
	troop = unit.get_node('Summons').get_children()
	current_summons = troop.size()
	
	for child in troop:
		child.bonus_health = child.bonus_health + (health_increase / current_summons)
		child.bonus_attack_damage = child.bonus_attack_damage + (attack_damage_increase / current_summons)
		child.bonus_speed = child.bonus_speed + (speed_increase/current_summons)
		child._update_totals()
		child.current_health = child.total_health
	queue_free()
