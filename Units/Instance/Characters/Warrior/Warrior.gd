extends player_variables
# Private Variables
@export_multiline var passive_name : String
@export_multiline var passive_tooltip : String
@export_multiline var passive_tooltip2 : String
@export var passive_icon : Texture
@export_multiline var active_name : String
@export_multiline var active_tooltip : String
@export_multiline var active_tooltip2 : String
@export var active_icon : Texture

var total_rage = 0
var base_rage = 100
var bonus_rage = 0
var current_rage = 0
var rage_regen = 3
var time_accumilated = 0
var rage_bar
# Private Methods
func _ready():
	HEALTH_LEVEL_UP_AMOUNT = 15
	MANA_LEVEL_UP_AMOUNT = 5
	STAMINA_LEVEL_UP_AMOUNT = 10
	STRENGTH_LEVEL_UP_AMOUNT = 10
	DEXTERITY_LEVEL_UP_AMOUNT = 3
	INTELLIGENCE_LEVEL_UP_AMOUNT = 2
	rage_bar = get_node("UI/ProgressBar3")

func _process(delta):
	super._process(delta)
	total_rage = base_rage + bonus_rage
	time_accumilated += delta
	if time_accumilated >= 1:
		time_accumilated = 0
		if current_rage < total_rage:
			current_rage += rage_regen
		if current_rage > total_rage:
			current_rage = total_rage
		rage_bar._update_rage(total_rage, current_rage)
	rage_bar._update_rage(total_rage, current_rage)

