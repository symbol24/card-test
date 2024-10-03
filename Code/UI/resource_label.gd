class_name ResourceLabel extends Label

@export var resource_type:CardData.Resource_Type

func _ready() -> void:
	Signals.ResourceUpdated.connect(_update_text)

func _update_text(_type:CardData.Resource_Type, _amount:int) -> void:
	if _type == resource_type:
		var letter = text.split(":",false,1)
		text = letter[0] + ":" + str(_amount)
