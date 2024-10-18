class_name UnlockTarget extends Resource

enum Target_Type {
					NOTHING = 0,
					DECK = 1,
					ACHIEVEMENT = 2,				
				}


@export var unlock_target_type:Target_Type
@export var unlock_target_id:String