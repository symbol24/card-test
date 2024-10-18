class_name UnlockManager extends Node


@export var deck_unlock_conditions:Array[UnlockCondition]

var to_unlock_decks:Array[DeckData] = []


func _ready() -> void:
	Signals.UnlockTarget.connect(_unlock_target)
	Signals.CheckDeckUnlock.connect(_check_deck_unlocks)
	Signals.CheckEndOfMatchDeckUnlocks.connect(_check_end_match_deck_unlocks)


func get_unclock_conditions_save_dict() -> Dictionary:
	var result:Dictionary = {}

	var deck_conditions:Dictionary = {}

	for unlock_condition in deck_unlock_conditions:
		var id:String = unlock_condition.id
		var unlocked:String = str(unlock_condition.already_unlocked)
		var conditions:Dictionary = {}
		var x:int = 0
		for condition in unlock_condition.conditions:
			conditions[x] = condition.current_amount
			x += 1
		
		deck_conditions[id] = {
								"unlocked": unlocked,
								"conditions": conditions,
								}
	result["deck_conditions"] = deck_conditions

	# This is where other conditions like achievements will be!

	return result


func set_deck_conditions(_dict:Dictionary) -> void:
	if not _dict.is_empty():
		#print(_dict)
		for unlock_condition in deck_unlock_conditions:
			if _dict.has(unlock_condition.id):
				var dict_unlock_conds:Dictionary = _dict[unlock_condition.id]

				if dict_unlock_conds.has("unlocked"):
					var dict_unlocked:bool = true if dict_unlock_conds["unlocked"] == "true" else false
					unlock_condition.already_unlocked = dict_unlocked

				if dict_unlock_conds.has("conditions"):
					#print("conditions? ", dict_unlock_conds["conditions"])
					var dict_conditions:Dictionary = dict_unlock_conds["conditions"]
					for x in unlock_condition.conditions.size()-1:
						if dict_conditions.has(str(x)):
							var dict_amount:int = int(dict_conditions[str(x)])
							unlock_condition.conditions[x].current_amount = dict_amount


func reset_conditions() -> void:
	for unlock in deck_unlock_conditions:
		unlock.already_unlocked = false
		for condition in unlock.conditions:
			condition.current_amount = 0


func _check_end_match_deck_unlocks(_result_id:String, _decks_used:Array) -> void:
	for unclock_cond in deck_unlock_conditions:
		if not unclock_cond.already_unlocked:
			var result:bool = unclock_cond.get_if_unlocked(_result_id, _decks_used)
			if result: unclock_cond.send_unlock_signals()


func _add_deck_to_unlock(_data:DeckData) -> void:
	#print("Unlock Manager received: ", _data.id)
	to_unlock_decks.append(_data)
	

func _unlock_target(_type:UnlockTarget.Target_Type, _target:String) -> void:
	match _type:
		UnlockTarget.Target_Type.DECK:
			var deck_data:DeckData = Game.data_manager.get_deck(_target, DeckData.Type.ANY)
			_add_deck_to_unlock(deck_data)


func _check_deck_unlocks() -> void:
	#print("decks to unlock size: ", to_unlock_decks.size())
	if not to_unlock_decks.is_empty():
		for each in to_unlock_decks:
			to_unlock_decks.erase(each)
			Signals.UnlockDeckInSave.emit(each)
		Signals.Save.emit()

