@tool
extends HBoxContainer
class_name DragSpinBox

signal value_changed(value:int)

@export var text : String = "" : set=set_text
func set_text(val:String):
	text = val
	_descript.text = val

@export var min_val : int = 0 : set=set_min_val
func set_min_val(val:int):
	min_val = min(val, max_val - 1)  # Ensure that this number is always smaller than max_val
	set_value(value)

@export var max_val : int = 100 : set=set_max_val
func set_max_val(val:int):
	max_val = max(val, min_val + 1)  # Ensure that this number is always larger than min_val
	set_value(value)
	
@export var step_incr : int = 1
@export var value : int : set=set_value
func set_value(val:int):
	val = clampi(val, min_val, max_val)
	val = snappedi(val, step_incr)
	value = val
	_val_label.text = str(val)

@export var drag_vertical : bool = false ## Is the user supposed to drag vertically rather than horizontally?
@export var drag_speed : int = 6 ## the ratio of pixels drag the value increment or decrement.


var _descript : Label
var _val_label : Label
func _init() -> void:
	var scene = preload("drag_spin_box.tscn").instantiate()
	add_child(scene)
	scene.owner = self
	
	_descript = scene.get_node("%Descript")
	_val_label = scene.get_node("%Val_Label")

	_descript.text = text
	_val_label.text = str(value)


var is_dragging : bool
var drag_start : float
var val_start : int

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and is_dragging:
		var drag_vect = [event.position.x, event.position.y][int(drag_vertical)] - drag_start
		drag_vect = inverse_lerp(0, 100, drag_speed) * drag_vect * [1, -1][int(drag_vertical)]
		value = snappedi(drag_vect + val_start, step_incr)
		value = clamp(value, min_val, max_val)
		_val_label.text = str(value)
	
	if event is InputEventMouseButton and not event.is_echo():
		is_dragging = event.is_pressed()
		if event.is_pressed():
			drag_start = [event.position.x, event.position.y][int(drag_vertical)]
			val_start = value
		elif val_start != value:
			value_changed.emit(value)
