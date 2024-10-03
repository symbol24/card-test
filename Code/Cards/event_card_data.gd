class_name EventCardData extends CardData


@export var rewards:Array[CardData]
@export var reward_amount:int = 1


func get_reward(_amount = reward_amount) -> CardData:
	var choice:int = Game.seeded_rng.randi_range(0, rewards.size()-1)
	return rewards[choice].duplicate()

