class_name PlayerData extends Resource


var weapons:int = 0:
	set(_value):
		weapons = _value
		Signals.ResourceUpdated.emit(CardData.Resource_Type.WEAPON, weapons)
var energy:int = 5:
	set(_value):
		energy = _value
		Signals.ResourceUpdated.emit(CardData.Resource_Type.ENERGY, energy)
var current_hp:int = 1:
	set(_value):
		current_hp = _value
		Signals.ResourceUpdated.emit(CardData.Resource_Type.HP, current_hp)

var current_deck:DeckData
var holding_card:bool = false


func update_all_resources() -> void:
	Signals.ResourceUpdated.emit(CardData.Resource_Type.WEAPON, weapons)
	Signals.ResourceUpdated.emit(CardData.Resource_Type.ENERGY, energy)
	Signals.ResourceUpdated.emit(CardData.Resource_Type.HP, current_hp)


func add_resource(_type:CardData.Resource_Type, _amount:int) -> void:
	match _type:
		CardData.Resource_Type.ENERGY:
			energy += _amount
		CardData.Resource_Type.WEAPON:
			weapons += _amount
		CardData.Resource_Type.HP:
			current_hp += _amount
		_:
			pass


func use_resource(_type:CardData.Resource_Type, _amount:int) -> void:
	match _type:
		CardData.Resource_Type.ENERGY:
			energy -= _amount
		CardData.Resource_Type.WEAPON:
			weapons -= _amount
		CardData.Resource_Type.HP:
			current_hp -= _amount
		_:
			pass


func check_available_resource(_type:CardData.Resource_Type, _amount:int) -> bool:
	var result:bool = false
	match _type:
		CardData.Resource_Type.ENERGY:
			if _amount <= energy: result = true
		CardData.Resource_Type.WEAPON:
			if _amount <= weapons: result = true
		CardData.Resource_Type.HP:
			if _amount < current_hp: result = true
		_:
			pass

	return result


func setup_player_data() -> void:
	current_hp = current_deck.starting_hp
	update_all_resources()
	print("setup_player_data done")