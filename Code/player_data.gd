class_name PlayerData extends Resource


var food:int = 0:
	set(_value):
		food = _value
		Signals.ResourceUpdated.emit(CardData.Resource_Type.FOOD, food)
var water:int = 0:
	set(_value):
		water = _value
		Signals.ResourceUpdated.emit(CardData.Resource_Type.WATER, water)
var material:int = 0:
	set(_value):
		material = _value
		Signals.ResourceUpdated.emit(CardData.Resource_Type.MATERIAL, material)
var weapons:int = 0:
	set(_value):
		weapons = _value
		Signals.ResourceUpdated.emit(CardData.Resource_Type.WEAPON, weapons)
var energy:int = 5:
	set(_value):
		energy = _value
		Signals.ResourceUpdated.emit(CardData.Resource_Type.ENERGY, energy)

var current_deck:DeckData
var current_hp:int = 1
var holding_card:bool = false

func update_all_resources() -> void:
	Signals.ResourceUpdated.emit(CardData.Resource_Type.FOOD, food)
	Signals.ResourceUpdated.emit(CardData.Resource_Type.WATER, water)
	Signals.ResourceUpdated.emit(CardData.Resource_Type.MATERIAL, material)
	Signals.ResourceUpdated.emit(CardData.Resource_Type.WEAPON, weapons)
	Signals.ResourceUpdated.emit(CardData.Resource_Type.ENERGY, energy)


func add_resource(_type:CardData.Resource_Type, _amount:int) -> void:
	match _type:
		CardData.Resource_Type.WATER:
			water += _amount
		CardData.Resource_Type.FOOD:
			food += _amount
		CardData.Resource_Type.ENERGY:
			energy += _amount
		CardData.Resource_Type.MATERIAL:
			material += _amount
		CardData.Resource_Type.WEAPON:
			weapons += _amount
		_:
			pass


func use_resource(_type:CardData.Resource_Type, _amount:int) -> void:
	match _type:
		CardData.Resource_Type.WATER:
			water -= _amount
		CardData.Resource_Type.FOOD:
			food -= _amount
		CardData.Resource_Type.ENERGY:
			energy -= _amount
		CardData.Resource_Type.MATERIAL:
			material -= _amount
		CardData.Resource_Type.WEAPON:
			weapons -= _amount
		_:
			pass


func check_available_resource(_type:CardData.Resource_Type, _amount:int) -> bool:
	var result:bool = false
	match _type:
		CardData.Resource_Type.WATER:
			if _amount <= water: result = true
		CardData.Resource_Type.FOOD:
			if _amount <= food: result = true
		CardData.Resource_Type.ENERGY:
			if _amount <= energy: result = true
		CardData.Resource_Type.MATERIAL:
			if _amount <= material: result = true
		CardData.Resource_Type.WEAPON:
			if _amount <= weapons: result = true
		_:
			pass

	return result
