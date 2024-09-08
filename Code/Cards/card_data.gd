class_name CardData extends Resource

enum Cost_Type {
                WATER,
                FOOD,
                MATERIAL,
                WEAPON,
                ENERGY
                }

enum Card_Type {
                NOTHING,
                TEST,
                TRASH,
                RESOURCE,
                ENEMY,
                CHALLENGE,
                }


@export var id:String
@export var title:String
@export var text:String
@export var cost_type:Array[Cost_Type]
@export var cost_amount:int
@export var image:Resource