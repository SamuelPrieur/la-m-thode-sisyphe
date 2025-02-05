extends Node2D

@onready var hz_slider = $HzSlider
@onready var right_radio = $RightRadio
@onready var left_radio = $LeftRadio
@onready var hz_label = $HzLabel

signal mini_game_completed(success: bool)

var audio_left_radio
var audio_right_radio
var target_frequency = 0
var frequency_tolerance = 5  # Marge d'erreur acceptable en Hz

var validation_timer: Timer
var is_frequency_correct = false

func _ready():
	audio_left_radio = AudioStreamPlayer.new()
	audio_right_radio = AudioStreamPlayer.new()
	
	add_child(audio_left_radio)
	add_child(audio_right_radio)
	
	audio_right_radio.stream = load("res://Assets/Audio/Action/RadioRight.wav")
	audio_left_radio.stream = load("res://Assets/Audio/Action/RadioLeft.wav")
	
	audio_right_radio.volume_db = -15
	audio_left_radio.volume_db = -15
	right_radio.pressed.connect(_on_right_radio_pressed)
	left_radio.pressed.connect(_on_left_radio_pressed)
	
	hz_slider.value_changed.connect(_on_slider_value_changed)
	
	# Initialiser le timer de validation
	validation_timer = Timer.new()
	validation_timer.wait_time = 0.5  # 1 seconde
	validation_timer.one_shot = true
	validation_timer.timeout.connect(_on_validation_timer_timeout)
	add_child(validation_timer)
	
	update_Hz()

func _on_right_radio_pressed():
	hz_slider.value += 75
	audio_right_radio.play()
	check_frequency()

func _on_left_radio_pressed():
	hz_slider.value -= 75
	audio_left_radio.play()
	check_frequency()

func _on_slider_value_changed(value: float):
	update_Hz()
	check_frequency()
		
func update_Hz():
	hz_label.text = str(hz_slider.value) + " Hz"

func set_target_frequency(freq: int):
	target_frequency = freq
	print("Target frequency set to: ", target_frequency)

func check_frequency():
	var current_freq = hz_slider.value
	var is_in_range = abs(current_freq - target_frequency) <= frequency_tolerance
	
	if is_in_range and !is_frequency_correct:
		is_frequency_correct = true
		validation_timer.start()
		print("Timer Start :", validation_timer)
	elif !is_in_range and is_frequency_correct:
		is_frequency_correct = false
		validation_timer.stop()
		print("Timer Stop :", validation_timer)

func _on_validation_timer_timeout():
	if is_frequency_correct:
		emit_signal("mini_game_completed", true)
		print("Timer Fini :", validation_timer)

func reset_game():
	hz_slider.value = 300  # Valeur de départ
	is_frequency_correct = false
	validation_timer.stop()
	update_Hz()
