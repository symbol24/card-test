class_name CardData extends Resource


enum Resource_Type {
				WATER = 0,
				FOOD = 1,
				MATERIAL = 2,
				WEAPON = 3,
				ENERGY = 4,
				HP = 5,
				}

enum Card_Type {
				NOTHING = 0,
				TEST = 1,
				TRASH = 2,
				RESOURCE = 3,
				ENEMY = 4,
				CHALLENGE = 5,
				}


@export var id:String
@export var title:String
@export var text:String
@export var type:Card_Type

@export_category("Card Costs")
@export var costs:Array[Cost]

@export_category("Resources")
@export var resources:Array[Cost]

@export_category("Rewards")
@export var rewards:Array[CardData]
@export var reward_amount:int = 0

@export_category("Extras")
@export var image:CompressedTexture2D
@export var is_mandatory:bool = false
@export var destroy_on_complete:bool = false

var cost_payed:bool:
	get:
		if costs.is_empty(): return true
		else:
			var all_payed:bool = true
			for each in costs:
				if not each.payed: 
					all_payed = false
					break
			return all_payed
var has_only_payables:bool:
	get:
		if costs.is_empty(): return true
		else:
			for each in costs:
				if not each.cost_type in payables:
					return false
			return true
var payment:Array[Cost]
var payables:Array[Resource_Type] = [Resource_Type.ENERGY, Resource_Type.WEAPON, Resource_Type.HP]


## Returns TRUE if the RESOURCES ARRAY contains at least 1 of TYPE.
func contains_resource(_type:Resource_Type) -> bool:
	for each in resources:
		if each.cost_type == _type:
			return true
	return false


## Returns TRUE if the COSTS ARRAY contains at least 1 of the RESOURCE TYPE.
func contains_cost(_type:Resource_Type) -> bool:
	for each in costs:
		if each.cost_type == _type:
			return true
	return false


## Returns a COST from the RESOURCES ARRAY based on the TYPE.
func get_resource(_type:Resource_Type) -> Cost:
	for each in resources:
		if each.cost_type == _type:
			return each
	return null


## Returns an ARRAY of CARDDATA based on the AMOUNT.
func get_reward(_amount = reward_amount) -> Array[CardData]:
	var returned: Array[CardData] = []
	var choice:int
	for i in _amount:
		choice = Game.seeded_rng.randi_range(0, rewards.size()-1)
		returned.append(rewards[choice].duplicate())
	return returned


## Assigns the VALUE to the first cost of TYPE encountered in the COSTS ARRAY.
func set_cost_payed(_type:Resource_Type = Resource_Type.WATER, _value:bool = false) -> void:
	for each in costs:
		if each.cost_type == _type:
			each.payed = _value
			break


## Reset all in COSTS ARRAY to not payed.
func reset_cost_payed() -> void:
	for each in costs:
		if not each.cost_type in payables:
			each.payed = false


## Returns first PAYABLE from COSTS, returns null if none found.
func get_payable() -> Cost:
	for each in costs:
		if each.cost_type in payables:
			return each
	return null