class_name DeckData extends Resource

enum Type {
            Player,
            Event
          }

@export var id:String
@export var cards:Array[CardData]