extends Area2D
signal has_hit(unit)
var hit_enemies = []
var hit_allies = false
var hit_allies_area = []
var tags = {}
var hit_timer = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_check_collision()
	hit_timer += delta

func _check_collision():
	var overlapping = self.get_overlapping_areas()
	for area in overlapping:
		if area.is_in_group('enemies') and area not in hit_enemies:
			hit_enemies.append(area)
			has_hit.emit(area)
		if area.is_in_group("players") or area.is_in_group("player_summon"):
			if hit_allies and area not in hit_allies_area:
				hit_allies_area.append(area)
				has_hit.emit(area)


func _on_particle_finished():
	queue_free()
