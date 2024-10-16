extends Node


const FOLDER:String = "user://save/"
const FILE:String = "game.save"
const PW:String = "NOTaPassword"


var data:SaveData


func _ready() -> void:
	Signals.Save.connect(_save)
	Signals.Load.connect(_load)
	Signals.DeleteSave.connect(_delete_save)


func _load():
	if not FileAccess.file_exists(FOLDER+FILE):
		print("creating new SAVE file")
		Signals.Save.emit()
		return {"result": "Missing save file"}

	var save_file = FileAccess.open_encrypted_with_pass(FOLDER+FILE, FileAccess.READ, PW)
	
	var json_string = save_file.get_line()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
	var save_file_data = json.get_data()
	save_file.close()
	data = SaveData.new()
	data.parse_json(save_file_data)
	print("Load Complete")
	print("Save count: ", data.save_count)


func _save() -> void:
	if not DirAccess.open(FOLDER):
		var _res = DirAccess.make_dir_absolute(FOLDER)
	var to_save := {"save":"data"}
	if data != null:
		to_save = data.get_save_dict()
	else:
		data = SaveData.new()
		to_save = data.get_save_dict()

	var save_file = FileAccess.open_encrypted_with_pass(FOLDER+FILE, FileAccess.WRITE, PW)
		
	var json_string = JSON.stringify(to_save)
	save_file.store_line(json_string)
	save_file.close()
	print("Save Complete")


func _delete_save() -> void:
	if FileAccess.file_exists(FOLDER+FILE):
		var dir = DirAccess.open(FOLDER)
		var result = dir.remove(FOLDER+FILE)
		if result == 0: 
			data = null
			print("Save file deleted")
		else: print("Delete save file error: ", result)