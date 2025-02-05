extends Node2D

signal keypad_code_generated(code)
@onready var code_label = $Code
var current_code = ""
var target_code = ""
const MAX_CODE_LENGTH = 4

func _ready():
	code_label.text = ""
	
	$KeyPad1.pressed.connect(func(): _on_key_pad_pressed(1))
	$KeyPad2.pressed.connect(func(): _on_key_pad_pressed(2))
	$KeyPad3.pressed.connect(func(): _on_key_pad_pressed(3))
	$KeyPad4.pressed.connect(func(): _on_key_pad_pressed(4))
	$KeyPad5.pressed.connect(func(): _on_key_pad_pressed(5))
	$KeyPad6.pressed.connect(func(): _on_key_pad_pressed(6))
	$KeyPad7.pressed.connect(func(): _on_key_pad_pressed(7))
	$KeyPad8.pressed.connect(func(): _on_key_pad_pressed(8))
	$KeyPad9.pressed.connect(func(): _on_key_pad_pressed(9))
	
	$KeyPadErase.pressed.connect(_on_key_pad_erase_pressed)
	$KeyPadEnter.pressed.connect(_on_key_pad_enter_pressed)
	get_parent().connect("keypad_code_generated", Callable(self, "_on_keypad_code_generated"))

func _on_key_pad_pressed(number):
	if current_code.length() < MAX_CODE_LENGTH:
		current_code += str(number)
		update_code_display()

func _on_key_pad_erase_pressed():
	if not current_code.is_empty():
		current_code = current_code.substr(0, current_code.length() - 1)
		update_code_display()

func _on_key_pad_enter_pressed():
	if current_code.length() == MAX_CODE_LENGTH:
		check_code()

func update_code_display():
	code_label.text = current_code

func _on_keypad_code_generated(code: String):
	target_code = code
	print("Code généré : ", target_code)

# Modifiez la fonction check_code()
func check_code():
	if current_code == target_code:
		print("Code correct !")
		get_parent().complete_current_task()  # Appel à la fonction de la scène parent
	else:
		print("Code incorrect.")
	
	current_code = ""
	update_code_display()
