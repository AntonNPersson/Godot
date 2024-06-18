extends Node2D
@export var interact_range = 100
@export var pop : Node
@export var offset = Vector2(-45, 0)
var popup = null
signal enter_portal()

func _ready():
	get_node('AnimationPlayer').play('portal appearing')
	popup = get_child(3).get_child(0)
	var interact_action = InputMap.action_get_events('Interact')
	if interact_action.size() > 0:
		interact_action = interact_action[0].as_text()
	else:
		interact_action = 'Interact'

	popup.get_child(0).text = 'Press ' + interact_action + ' to enter the portal'
	popup.get_child(0).global_position += offset


func _process(delta):
	var players = get_tree().get_nodes_in_group('players')
	for player in players:
		if player.get_position().distance_to(get_position()) < interact_range:
			popup.visible = true
			if Input.is_action_just_pressed('Interact'):
				enter_portal.emit()
				queue_free()
		else:
			popup.visible = false

func _on_animation_player_animation_finished(anim_name:StringName):
	if anim_name == "portal appearing":
		get_node('AnimationPlayer').play('portal rotating')
