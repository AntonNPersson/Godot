extends RichTextLabel

var text_queue := []
var current_text = ""
var target_text = ""
var typing_speed = 30.0
var sped_typing_speed = 70.0  # Adjust the typing speed as needed
var typing_timer = Timer.new()
var timeout_time = 3
var is_typing_initiated = false
var is_queue_completed = false
var info_label: Label
signal typing_finished()
signal next_typing()

func _ready():
	add_child(typing_timer)
	typing_timer.one_shot = false
	typing_timer.timeout.connect(_on_typing_timer_timeout)
	info_label = get_parent().get_node('Label')

func _process(delta):
	if is_typing_initiated:
		if Input.is_action_pressed("Continue"):
			typing_timer.wait_time = 1.0 / sped_typing_speed
		else:
			typing_timer.wait_time = 1.0 / typing_speed
	else:
		typing_timer.wait_time = 1.0 / typing_speed
# Method to initiate the typing effect with the given text
func _start_typing(text_to_type: Array, time):
	text_queue = text_to_type
	timeout_time = time

	if !is_typing_initiated and !is_queue_completed:
		_start_next_typing()

func _start_next_typing():
	if text_queue.size() > 0:
		var next_text = text_queue.front()
		target_text = next_text
		current_text = ""
		is_typing_initiated = true
		typing_timer.wait_time = 1.0 / typing_speed
		typing_timer.start()

# Method called on typing timer timeout
func _on_typing_timer_timeout():
	if current_text.length() + 1 <= target_text.length():
		current_text = target_text.substr(0, current_text.length() + 1)
		set_text(current_text)
	else:
		info_label.text = 'Press "Space" to continue'
		if Input.is_action_just_released("Continue"):
			is_typing_initiated = false
			typing_timer.stop()
			text_queue.pop_front()
			var is_last_text = text_queue.size() == 0
			if !is_last_text:
				next_typing.emit()
				await get_tree().create_timer(timeout_time).timeout
				_start_next_typing()
			else:
				_reset()

func _reset():
		current_text = ""
		set_text(current_text)
		is_queue_completed = false
		text_queue.clear()
		typing_finished.emit()

# Method to reset the queue
func _is_typing_finished():
	return is_queue_completed
# Example usage
