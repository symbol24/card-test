class_name SceneManager extends Node


@export var level_data:LevelData

var active_level:Node
var is_loading := false
var to_load := ""
var load_complete := false
var loading_status := 0.0
var progress := []
var ui:CanvasLayer


func _ready() -> void:
	# Process mode is set to "always" through code
	process_mode = PROCESS_MODE_ALWAYS
	
	ui = get_tree().get_first_node_in_group("UI") as CanvasLayer

	Signals.LoadScene.connect(_load_scene)

	if level_data == null: push_error("Level data in scene manager is not set.")


func _process(_delta: float) -> void:
	if is_loading:
		loading_status = ResourceLoader.load_threaded_get_status(to_load, progress)
		
		# When loading is complete in ResourceLoader, launch the _complete_load function.
		if loading_status == ResourceLoader.THREAD_LOAD_LOADED:
			if !load_complete:
				load_complete = true
				_complete_load()
	

func _load_scene(_id:String = "") -> void:
	# Send loadscreen toggle on
	Signals.ToggleLoadingScreen.emit(true)
	get_tree().paused = true
	
	# If path is empty, dont try to load.
	var path:String = level_data.get_level_path(_id)
	if path == "":
		push_error("Path to load is empty.")
		return
	
	# If there is an active level, queue_free it.
	if active_level != null: 
		var temp := active_level
		ui.level_layer.remove_child.call_deferred(temp)
		temp.queue_free.call_deferred()
	
	# Starting the ResourceLoader.
	to_load = path
	is_loading = true
	load_complete = false
	ResourceLoader.load_threaded_request(to_load)


func _complete_load() -> void:
	is_loading = false
	
	# Get the new level from the ResourceLoader and instantiate it.
	var new_level := ResourceLoader.load_threaded_get(to_load)
	active_level = new_level.instantiate()
	ui.level_layer.add_child.call_deferred(active_level)
	
	if not active_level.is_node_ready():
		await active_level.ready
	
	get_tree().paused = false
	Signals.SceneLoadingComplete.emit()