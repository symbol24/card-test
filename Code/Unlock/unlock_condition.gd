class_name UnlockCondition extends Resource


enum Type {
			INCREMENTAL = 0,
			SAMETIME = 1,
		}

@export var id:String
@export var type:Type
@export var conditions:Array[Condition]
@export var to_unlock:Array[UnlockTarget]
@export var already_unlocked:bool = false


func get_if_unlocked(_condition_id:String, _targets:Array) -> bool:
	#print("Checking Condition ", id)
	#print("Condition id: ", _condition_id)
	#print("Targets: ", _targets)
	var result:bool = false
	for target in _targets:
		#print("Checking target: ", target)
		var condition:Condition = _get_condition_from_id(target)
		#print("Condition? ", condition)
		#if condition != null:
			#print("Is condition complete? ", condition.is_condition_complete())
			#print("Checking condition: ", condition.check_condition(_condition_id, target))
		if condition != null and not condition.is_condition_complete() and condition.check_condition(_condition_id, target):
			condition.current_amount += 1
			#print(condition.current_amount)
			if condition.is_condition_complete(): result = true
			else: result = false

	if result and type == Type.SAMETIME:
		var tot:int = 0
		for each in conditions:
			if each.is_condition_complete(): tot += 1

		#print("total complete: ", tot, " conditions count: ", conditions.size())
		if tot == conditions.size():
			result = true
		else:
			result = false
			for each in conditions:
				each.current_amount = 0

	#print("Returning condition complete: ", result)
	#print("----------------------------")
	return result


func send_unlock_signals() -> void:
	#print("to unlock size: ", to_unlock.size())
	for each in to_unlock:
		#print("Sending Unlock for ", each.unlock_target_id)
		Signals.UnlockTarget.emit(each.unlock_target_type, each.unlock_target_id)
	already_unlocked = true


func _get_condition_from_id(_id:String) -> Condition:
	for each in conditions:
		#print(each.condition_target, " == ", _id)
		if each.condition_target == _id:
			return each
	return null