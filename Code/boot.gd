extends Node2D

func _ready() -> void:
    UI.ToggleUi.emit("main_menu", true, "main_menu")