extends Item
class_name Aeolus
var epic
var unique
var knockback_distance: int
var duration: int
var color = Color.LIGHT_CORAL
var cooldown

func _initialize():
	knockback_distance = 50
	duration = 0
	cooldown = randi() % 10 + 4
	epic = 'OnCast'
	unique = true
	tags.append("WindShout")
	values.append(knockback_distance)
	colors.append(color)

	tooltip = "On Cast: An explosion of wind knocks back surrounding enemies for " + str(knockback_distance) + "pixels, has a " + str(cooldown) + "seconds cooldown."
