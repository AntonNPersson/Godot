extends Node

func _create_timer(wait_time: float, one_shot: bool, parent: Node):
    var timer = Timer.new()
    timer.wait_time = wait_time
    timer.one_shot = one_shot
    parent.add_child(timer)
    return timer
