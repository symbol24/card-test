class_name SaveData extends Resource


@export var unlocked_player_decks:Array = []
@export var unlocked_event_decks:Array = []


var save_count:int = 0


func get_save_dict() -> Dictionary:
	save_count += 1
	return {
			"unlocked_player_decks": unlocked_player_decks,
			"unlocked_event_decks": unlocked_event_decks,
			"save_count":save_count,
			}


func parse_json(_data) -> void:
	if _data.has("unlocked_player_decks"): unlocked_player_decks = _data["unlocked_player_decks"] as Array
	if _data.has("unlocked_event_decks"): unlocked_event_decks = _data["unlocked_event_decks"] as Array
	if _data.has("save_count"): save_count = _data["save_count"] as int