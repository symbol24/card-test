extends Node

#UI
signal ButtonPressed(id:String, from:String)

# GAME
signal AddResource(type:CardData.Resource_Type, amount:int)
signal UseResource(type:CardData.Resource_Type, amount:int)
signal ResourceUpdated(type:CardData.Resource_Type, amount:int)
signal DiscardCard(card:Card)
signal UseCard(card:Card)
signal ToggleColliders(value:bool)
