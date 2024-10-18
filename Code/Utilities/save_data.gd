class_name SaveData extends Resource


@export var unlocked_player_decks:Array = []
@export var unlocked_event_decks:Array = []


var save_count:int = 0


func get_save_dict() -> Dictionary:
	save_count += 1
	var result:Dictionary = Game.unlock_manager.get_unclock_conditions_save_dict()
	result.merge({
			"unlocked_player_decks": unlocked_player_decks,
			"unlocked_event_decks": unlocked_event_decks,
			"save_count":save_count,
			})
	#print(result)
	return result


func parse_json(_data) -> void:
	if _data.has("unlocked_player_decks"): 
		for each:String in _data["unlocked_player_decks"]:
			unlocked_player_decks.append(each)
	if _data.has("unlocked_event_decks"):
		for each:String in _data["unlocked_event_decks"]:
			unlocked_event_decks.append(each)
	if _data.has("save_count"): save_count = _data["save_count"] as int
	if _data.has("deck_conditions"): Game.unlock_manager.set_deck_conditions(_data["deck_conditions"])


func is_deck_unlocked_by_id(_id:String) -> bool:
	for each in unlocked_player_decks:
		if each == _id: return true
	for each in unlocked_event_decks:
		if each == _id: return true
	return false


func add_unlocked_deck(_data:DeckData) -> void:
	if _data.type == DeckData.Type.EVENT:
		unlocked_event_decks.append(_data.id)
	else:
		unlocked_player_decks.append(_data.id)
