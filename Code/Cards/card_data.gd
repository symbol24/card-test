class_name CardData extends Resource

enum Resource_Type {
				WATER = 0,
				FOOD = 1,
				MATERIAL = 2,
				WEAPON = 3,
				ENERGY = 4,
				DAMAGE = 5,
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

var cost_payed:bool = false
var payment:Array[Cost]


func contains_resource(_type:Resource_Type) -> bool:
	for each in resources:
		if each.cost_type == _type:
			return true
	return false


func get_resource(_type:Resource_Type) -> Cost:
	for each in resources:
		if each.cost_type == _type:
			return each
	return null


func get_reward(_amount = reward_amount) -> CardData:
	var choice:int = Game.seeded_rng.randi_range(0, rewards.size()-1)
	return rewards[choice].duplicate()