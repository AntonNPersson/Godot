extends Node2D

var screen_size : Vector2
var margin : float = 20.0  # Distance from screen edge
var indicator_scene : PackedScene
var indicators : Dictionary = {}

func _ready():
    screen_size = get_viewport_rect().size

func _process(delta):
    #update_indicators()
    pass

func update_indicators():
    for projectile in get_tree().get_nodes_in_group("projectile"):
        if not is_in_viewport(projectile):
            show_indicator(projectile)
        else:
            remove_indicator(projectile)

func is_in_viewport(node: Node2D) -> bool:
    var cam = get_viewport().get_camera_2d()
    var pos = cam.global_transform.basis_xform_inv(node.global_position)
    return get_viewport_rect().has_point(pos)

func show_indicator(projectile: Node2D):
    if not indicators.has(projectile):
        var indicator = duplicate()
        indicator.visible = true
        get_tree().current_scene.add_child(indicator)
        indicators[projectile] = indicator
    
    var indicator = indicators[projectile]
    var pos = calculate_indicator_position(projectile.global_position)
    indicator.global_position = pos
    indicator.rotation = (projectile.global_position - global_position).angle()

func remove_indicator(projectile: Node2D):
    if indicators.has(projectile):
        indicators[projectile].queue_free()
        indicators.erase(projectile)

func calculate_indicator_position(projectile_pos: Vector2) -> Vector2:
    var cam = get_viewport().get_camera_2d()
    var viewport_pos = cam.global_transform.basis_xform_inv(projectile_pos)
    var center = screen_size / 2
    var angle = (viewport_pos - center).angle()
    
    var offset = Vector2(cos(angle), sin(angle)) * (center - Vector2(margin, margin))
    return cam.global_transform.basis_xform(center + offset)