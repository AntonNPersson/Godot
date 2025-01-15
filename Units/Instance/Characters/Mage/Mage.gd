extends player_variables
# Private Variables
@export var level_up_menu : PackedScene
@export_multiline var passive_name : String
@export_multiline var passive_tooltip : String
@export_multiline var passive_tooltip2 : String
@export var passive_icon : Texture
@export var passive_increase : int
@export_multiline var active_name : String
@export_multiline var active_tooltip : String
@export_multiline var active_tooltip2 : String
@export var active_icon : Texture
# Private Methods
func _ready():
	HEALTH_LEVEL_UP_AMOUNT = 5
	MANA_LEVEL_UP_AMOUNT = 15
	STAMINA_LEVEL_UP_AMOUNT = 10
	STRENGTH_LEVEL_UP_AMOUNT = 2
	DEXTERITY_LEVEL_UP_AMOUNT = 3
	INTELLIGENCE_LEVEL_UP_AMOUNT = 10

func _process(delta):
	super._process(delta)
	_character_passive()

func _character_passive():
	var extra = {'ability': passive_name}
	get_node('Control').on_action.emit(total_intelligence/10, self, self, "BoostManaRegenPassive", extra)

