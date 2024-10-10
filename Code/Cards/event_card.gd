class_name EventCard extends Card


@export var flash_delay:float = 0.3


func flash_card(_color:Color) -> void:
	var tween:Tween = self.create_tween()
	var time:float = flash_delay/2
	tween.tween_property(self, "modulate", _color, time)
	tween.tween_property(self, "modulate", Color.WHITE, time)