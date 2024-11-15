extends Node2D
@export var i_name : String
@export_multiline var tooltip : String
@export var icon : Texture

var size : float
var cooldown : float
var tags : Array
var values : Array
@export var after_effect : PackedScene
var cast_duration : float

var special = false
var player = null
var map = null
var timer = 0

var ascension_currency_multiplier = 0.4

var second_tooltip

func _ready():
	second_tooltip = "Meteors shower from the sky every second, dealing damage based on the ascension level."

func _start_special(players, maps):
	size = 1.25
	cooldown = 1.0
	cast_duration = 1
	tags = ["Damage"]
	values = [50.0 * players.ascension_level]
	player = players
	map = maps
	timer = 0
	special = true

func _stop_special():
	special = false

func _update_special(delta):
	if special:
		timer += delta
		if timer >= cooldown:
			timer = 0
			_use()

func _do_action():
	for i in range(0, values.size()):
		player.get_node('Control').on_action.emit(values[i], player, player, tags[i])

func _use():
	var callable = Callable(self, '_do_action')
	Utility.get_node('EnemyTargetSystem')._create_targeted_circle_ability(size, cast_duration, map._get_random_walkable_tile(), player, callable, after_effect)
