class_name Condition extends Resource


enum Type {
					PLAYWITH = 0,
					WINWITH = 1,
					FAILWITH = 2,
					INTERACT = 3,
				}

@export var condition_type:Type
@export var condition_target:String
@export var amount_needed:int = 1

var current_amount:int = 0:
	set(value):
		current_amount = value
		#print("Current amount set to: ", current_amount)


func is_condition_complete() -> bool:
	#print("amount_needed: ", amount_needed, "| current_amount: ", current_amount)
	return current_amount >= amount_needed


func check_condition(_condition_id:String, _target:String) -> bool:
	var result:bool = false
	var target_match:bool = true if _target == condition_target else false
	#print("Condition string: ", _condition_id)
	#print("_target ", _target, " == condition_target ", condition_target)
	var condition_match:bool = false

	match condition_type:
		Type.PLAYWITH, Type.WINWITH, Type.FAILWITH:
			if _condition_id.contains("failure") and (condition_type == Type.FAILWITH or condition_type == Type.PLAYWITH):
				condition_match = true
			elif _condition_id.contains("success") and (condition_type == Type.WINWITH or condition_type == Type.PLAYWITH):
				condition_match = true
				
		Type.INTERACT:
			if _condition_id.contains("interact") and condition_type == Type.INTERACT:
				condition_match = true

		_:
			pass


	result = target_match and condition_match

	return result
