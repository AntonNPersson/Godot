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
# Private Methods
func _ready():
	HEALTH_LEVEL_UP_AMOUNT = 5
	MANA_LEVEL_UP_AMOUNT = 12.5
	STAMINA_LEVEL_UP_AMOUNT = 12.5
	STRENGTH_LEVEL_UP_AMOUNT = 10
	DEXTERITY_LEVEL_UP_AMOUNT = 0
	INTELLIGENCE_LEVEL_UP_AMOUNT = 10

func _process(delta):
	super._process(delta)
	_character_passive()

func _character_passive():
	var extra = {'ability': passive_name}
	get_node('Control').on_action.emit(2 * player_level, self, self, "DoubleCastPassive", extra)

