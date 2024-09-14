class_name SyRandomNumberGenerator extends RandomNumberGenerator

var previous_seed:String
var current_seed:String


func check_seed_changed() -> bool:
	if current_seed == previous_seed: push_warning("SyRandomNumberGenerator seed has not been updated.")
	return current_seed == previous_seed
