class_name GrabberSelectorPanel extends Panel


@onready var collider:CollisionShape2D = %collider



func set_panel_size(_mouse_pos:Vector2) -> void:
	var new_size:Vector2
	var new_scale:Vector2
	if _mouse_pos.x < global_position.x and _mouse_pos.y < global_position.y:
		new_size = global_position - _mouse_pos
		new_scale = Vector2(-1,-1)
	elif _mouse_pos.x < global_position.x and _mouse_pos.y > global_position.y:
		new_size = Vector2(global_position.x - _mouse_pos.x, _mouse_pos.y - global_position.y)
		new_scale = Vector2(-1,1)
	elif _mouse_pos.x > global_position.x and _mouse_pos.y < global_position.y:
		new_size = Vector2(_mouse_pos.x - global_position.x, global_position.y - _mouse_pos.y)
		new_scale = Vector2(1,-1)
	else:
		new_size = _mouse_pos - global_position
		new_scale = Vector2(1,1)


	print("Size: ", new_size, " and scale: ", scale)

	set_deferred("size", new_size)
	set_deferred("scale", new_scale)
	collider.set_deferred("position", new_size/2)
	collider.shape.set_deferred("new_size", new_size)