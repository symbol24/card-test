class_name PlayerData extends Resource

var food:int = 0:
    set(_value):
        food = _value
        Game.ResourceUpdated.emit(CardData.Cost_Type.FOOD, food)
var water:int = 0:
    set(_value):
        water = _value
        Game.ResourceUpdated.emit(CardData.Cost_Type.WATER, water)
var material:int = 0:
    set(_value):
        material = _value
        Game.ResourceUpdated.emit(CardData.Cost_Type.MATERIAL, material)
var weapons:int = 0:
    set(_value):
        weapons = _value
        Game.ResourceUpdated.emit(CardData.Cost_Type.WEAPON, weapons)
var energy:int = 5:
    set(_value):
        energy = _value
        Game.ResourceUpdated.emit(CardData.Cost_Type.ENERGY, energy)

func update_all_resources() -> void:
    Game.ResourceUpdated.emit(CardData.Cost_Type.FOOD, food)
    Game.ResourceUpdated.emit(CardData.Cost_Type.WATER, water)
    Game.ResourceUpdated.emit(CardData.Cost_Type.MATERIAL, material)
    Game.ResourceUpdated.emit(CardData.Cost_Type.WEAPON, weapons)
    Game.ResourceUpdated.emit(CardData.Cost_Type.ENERGY, energy)

func add_resource(_type:CardData.Cost_Type, _amount:int) -> void:
    match _type:
        CardData.Cost_Type.WATER:
            water += _amount
        CardData.Cost_Type.FOOD:
            food += _amount
        CardData.Cost_Type.ENERGY:
            energy += _amount
        CardData.Cost_Type.MATERIAL:
            material += _amount
        CardData.Cost_Type.WEAPON:
            weapons += _amount
        _:
            pass

func use_resource(_type:CardData.Cost_Type, _amount:int) -> void:
    match _type:
        CardData.Cost_Type.WATER:
            water -= _amount
        CardData.Cost_Type.FOOD:
            food -= _amount
        CardData.Cost_Type.ENERGY:
            energy -= _amount
        CardData.Cost_Type.MATERIAL:
            material -= _amount
        CardData.Cost_Type.WEAPON:
            weapons -= _amount
        _:
            pass

func check_available_resource(_type:CardData.Cost_Type, _amount:int) -> bool:
    var result:bool = false
    match _type:
        CardData.Cost_Type.WATER:
            if _amount <= water: result = true
        CardData.Cost_Type.FOOD:
            if _amount <= food: result = true
        CardData.Cost_Type.ENERGY:
            if _amount <= energy: result = true
        CardData.Cost_Type.MATERIAL:
             if _amount <= material: result = true
        CardData.Cost_Type.WEAPON:
             if _amount <= weapons: result = true
        _:
            pass

    return result