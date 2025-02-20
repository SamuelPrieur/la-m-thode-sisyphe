extends Button
class_name MultiTouchButtonNob

@export var icon_position1: Texture
@export var icon_position2: Texture
@export var icon_position3: Texture

var position_icons = []
var current_icon_index = 0

func _ready():
	# Initialisation des icônes dans un tableau
	position_icons = [icon_position1, icon_position2, icon_position3]
	
	# Vérifier que les icônes ne sont pas null avant d'appliquer la première
	if position_icons[0] != null:
		icon = position_icons[current_icon_index]

func _gui_input(event):
	var event_pos_adjusted = event.position + global_position
	var inside = event_pos_adjusted.x > position.x and event_pos_adjusted.y > position.y and event_pos_adjusted.x < position.x + size.x and event_pos_adjusted.y < position.y + size.y
	
	if event is InputEventScreenTouch and event.pressed and inside:
		# Cycle entre les icônes
		if position_icons.size() > 0:
			current_icon_index = (current_icon_index + 1) % position_icons.size()
			if position_icons[current_icon_index] != null:
				icon = position_icons[current_icon_index]

		if toggle_mode:
			toggled.emit()
			button_pressed = true
		else:
			pressed.emit()
			button_down.emit()
		
	elif (event is InputEventScreenTouch and inside) or (event is InputEventScreenTouch and !event.pressed and !inside):
		button_up.emit()
		button_pressed = false
