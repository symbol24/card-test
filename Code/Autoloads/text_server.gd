extends Node

const ENERGYTAG:String = "[energy]"
const HPTAG:String = "[hp]"
const WATERTAG:String = "[water]"
const FOODTAG:String = "[food]"
const MATERIALTAG:String = "[material]"
const WEAPONTAG:String = "[weapon]"
const COSTTAG:String = "[cost]"
const RESOURCETAG:String = "[resources]"

const ENERGYREPLACEMENT:String = "[color=darkorange]energy[/color]"
const HPREPLACEMENT:String = "[color=red]HPTAG[/color]"
const WATERREPLACEMENT:String = "[color=lightblue]water[/color]"
const FOODREPLACEMENT:String = "[color=green]food[/color]"
const MATERIALREPLACEMENT:String = "[color=darkgray]material[/color]"
const WEAPONREPLACEMENT:String = "[color=black]weapon[/color]"







func replace_tags(_text:String = "", _card:CardData = null) -> String:
	if _text == "": return _text

	_text = _text.replace(ENERGYTAG, "energy")
	_text = _text.replace(HPTAG, "HPTAG")
	_text = _text.replace(WATERTAG, "water")
	_text = _text.replace(FOODTAG, "food")
	_text = _text.replace(MATERIALTAG, "material")
	_text = _text.replace(WEAPONTAG, "weapon")

	if _text.contains(COSTTAG) and _card != null:
		_text = _text.replace(COSTTAG, _get_cost(_card.costs))

	if _text.contains(RESOURCETAG) and _card != null:
		_text = _text.replace(RESOURCETAG, _get_cost(_card.resources))

	if _card != null:
		_text = _replace_seperated_costs(_text, _card.resources)

	if _card != null:
		_text = _replace_seperated_costs(_text, _card.resources, true)

	return _text


func _get_cost(_array:Array[Cost] = []) -> String:
	var to_return:String = ""
	var i:int = 0
	for cost in _array:
		if i > 0: to_return += ", "
		for x in cost.cost_amount:
			if x > 0: to_return += ", "
			to_return += _get_type_replacement(cost.cost_type)
		i += 1
		
	return to_return


func _replace_seperated_costs(_text:String = "", _array:Array[Cost] = [], is_cost:bool = false) -> String:
	if _text == "": return _text

	var i:int = 1
	for cost in _array:
		var to_replace:String = "[c" if is_cost else "[r"
		
		to_replace += str(i) + "]"
		_text = _text.replace(to_replace, _get_type_replacement(cost.cost_type))
		i += 1
	return _text


func _get_type_replacement(_type:CardData.Resource_Type) -> String:
	var to_return:String = ""
	match _type:
		CardData.Resource_Type.WATER:
			to_return += WATERREPLACEMENT
		CardData.Resource_Type.ENERGY:
			to_return += ENERGYREPLACEMENT
		CardData.Resource_Type.FOOD:
			to_return += FOODREPLACEMENT
		CardData.Resource_Type.HP:
			to_return += HPREPLACEMENT
		CardData.Resource_Type.MATERIAL:
			to_return += MATERIALREPLACEMENT
		CardData.Resource_Type.WEAPON:
			to_return += WEAPONREPLACEMENT
		_:
			pass
	return to_return