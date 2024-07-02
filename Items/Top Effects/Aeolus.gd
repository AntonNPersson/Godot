extends Item
class_name Aeolus
var epic
var knockback_distance: int
var duration: int
var color = Color.LIGHT_CORAL

func _initialize():
	knockback_distance = 50
	duration = 0
	epic = 'OnCast'
	tags.append("WindShout")
	values.append(knockback_distance)
	colors.append(color)

	tooltip = "On Cast: An explosion of wind knocks back surrounding enemies for " + str(knockback_distance) + "pixels."
