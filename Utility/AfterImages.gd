extends Node2D
var after_images = []
var after_image_speed = 2
var original_sprite

func _create_after_image(origin, speed = 2):
	after_image_speed = speed
	original_sprite = origin.get_node("AnimatedSprite2D")
	var after_image = origin.get_node("AnimatedSprite2D").duplicate()
	after_image.global_position = origin.global_position
	after_image.material = null
	after_image.modulate.a = 0.5
	origin.get_tree().get_root().get_node('Main').add_child(after_image)
	after_images.append(after_image)

func _process(delta):
	for image in after_images:
		image.play(original_sprite.animation)
		image.frame = original_sprite.frame
		image.modulate.a -= delta * after_image_speed
		if image.modulate.a <= 0:
			image.queue_free()
			after_images.erase(image)