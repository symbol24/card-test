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
@export var costs:Array[Cost]
@export var resources:Array[Cost]
@export var image:CompressedTexture2D
@export var is_mandatory:bool = false

var cost_payed:bool = false
var payment:Array[Cost]