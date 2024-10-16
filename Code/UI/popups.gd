class_name SyPopups extends PanelContainer


# Big popup
@onready var big_popup:PanelContainer = %big_popup
@onready var popup_button_1:Button = %PopupButton1
@onready var popup_button_2:Button = %PopupButton2
@onready var popup_button_3:Button = %PopupButton3
@onready var big_popup_title:RicherTextLabel = %big_popup_title
@onready var big_popup_text:RicherTextLabel = %big_popup_text
@onready var delay_timer:RichTextAnimation = %delay_timer

# Small popup
@onready var small_popup:PanelContainer = %small_popup
@onready var small_popup_text:RichTextAnimation = %small_popup_text

# Big popup timer
var timer_active:bool = false
var timer:float = 0.0:
	set(value):
		timer = value
		if timer <= 0.0:
			timer = 0.0
			timer_active = false
var seconds:float = 1.0:
	set(value):
		seconds = value

# Small popup timer
var small_timer_active:bool = false
var small_timer:float = 0.0:
	set(value):
		small_timer = value
		if small_timer <= 0.0:
			small_timer = 0.0
			small_timer_active = false
			_close_small_popup()


func _ready() -> void:
	Signals.DisplaySmallPopup.connect(_display_small_popup)
	Signals.DisplayBigPopup.connect(_display_big_popup)
	popup_button_1.pressed.connect(_btn_1_pressed)
	popup_button_2.pressed.connect(_btn_2_pressed)
	popup_button_3.pressed.connect(_btn_3_pressed)


func _process(delta: float) -> void:
	if timer_active: 
		timer -= delta
		seconds -= delta
	if small_timer_active: small_timer -= delta


func _update_time_display(_value:int) -> void:
	delay_timer.set_deferred("bbcode", (_value))


func _display_big_popup(_title:String, _text:String, _timer:int = 0, _has_btn_1:bool = true, _has_btn_2:bool = true,_has_btn_3:bool = false) -> void:
	big_popup_title.set_deferred("text", (_title))
	big_popup_text.set_deferred("text", (_text))
	big_popup.set_deferred("visible", true)
	_set_btn(popup_button_1, _has_btn_1)
	_set_btn(popup_button_2, _has_btn_2)
	_set_btn(popup_button_3, _has_btn_3)
	if _timer > 0:
		timer = _timer
		timer_active = true
		delay_timer.set_deferred("bbcode", (_timer))
		delay_timer.set_deferred("visible", true)
	else:
		delay_timer.set_deferred("visible", false)


func _close_big_popup() -> void:
	if timer_active:
		timer = 0.0
		timer_active = false
	big_popup.set_deferred("visible", false)


func _set_btn(_btn:Button, _has_btn:bool = true) -> void:
	if _has_btn:
		_btn.set_deferred("visible", true)
	else:
		_btn.set_deferred("visible", false)


func _display_small_popup(_text:String, _timer:float = 5.0) -> void:
	small_popup.set_deferred("visible", true)
	small_popup_text.set_deferred("bbcode", (_text))
	small_timer = _timer
	small_timer_active = true


func _close_small_popup() -> void:
	small_popup.set_deferred("visible", false)


func _btn_1_pressed() -> void:
	pass


func _btn_2_pressed() -> void:
	pass


func _btn_3_pressed() -> void:
	pass