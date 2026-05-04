@tool
extends HBoxContainer
class_name DragSpinBox

signal value_changed(value:int)

@export var text : String = "" : 
	set(val):
		text = val
		if not is_node_ready():
			await ready
		_descript.text = val

@export var suffix : String = "" :
	set(val):
		suffix = val
		if not is_node_ready():
			await ready
		_suffix.text = val

@export var min_val : int = 0 : 
	set(val):
		min_val = min(val, max_val - 1)  # Ensure that this number is always smaller than max_val
		value = value

@export var max_val : int = 100 : 
	set(val):
		max_val = max(val, min_val + 1)  # Ensure that this number is always larger than min_val
		value = value
	
@export var step_incr : int = 1
@export var value : int : 
	set(val):
		val = clampi(val, min_val, max_val)
		val = snappedi(val, step_incr)
		value = val
		if not is_node_ready():
			await ready
		_value.text = str(val)

@export var drag_vertical : bool = false ## Is the user supposed to drag vertically rather than horizontally?
@export var drag_speed : int = 6 ## the ratio of pixels drag the value increment or decrement.

var _descript := Label.new()
var _value := Label.new()
var _suffix := Label.new()

func _init() -> void:
	_descript.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_value.text = "0"
	add_child(_descript)
	add_child(_value)
	add_child(_suffix)

var is_dragging : bool
var drag_start : float
var val_start : int

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and is_dragging:
		var drag_vect = [event.position.x, event.position.y][int(drag_vertical)] - drag_start
		drag_vect = inverse_lerp(0, 100, drag_speed) * drag_vect * [1, -1][int(drag_vertical)]
		value = snappedi(drag_vect + val_start, step_incr)
		value = clamp(value, min_val, max_val)
	
	if event is InputEventMouseButton and not event.is_echo():
		is_dragging = event.is_pressed()
		if event.is_pressed():
			drag_start = [event.position.x, event.position.y][int(drag_vertical)]
			val_start = value
		elif val_start != value:
			value_changed.emit(value)
