@tool
class_name Reset extends Node


@onready var parent:RichTextAnimation = get_parent()


func reset(_value:float) -> void:
	parent.progress = _value