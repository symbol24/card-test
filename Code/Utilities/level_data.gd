class_name LevelData extends Resource


@export var levels:Dictionary = {}
@export var extra_loading_time:float = 0.0


func get_level_path(_id:String) -> String:
	if levels.has(_id): return levels[_id]
	push_error("Level witn id'", _id, "' could not be found in level data.")
	return ""