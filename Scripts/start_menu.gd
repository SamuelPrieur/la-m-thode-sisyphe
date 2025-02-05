extends Control

@onready var light_tv = $LightTV
@onready var start_button = $StartButton  
@onready var exit_button = $ExitButton

var audio_player

var accumulated_time = 0.0
var next_change_time = 0.0

func _ready():
	Global.score = 0
	Global.level = 1
	_generate_next_change_time()

	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	audio_player.volume_db = -10
	
	audio_player.stream = load("res://Assets/Audio/Action/Menu.wav")
	audio_player.finished.connect(_on_audio_finished)

	start_button.pressed.connect(_on_start_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)

# ----------------------- Animation de la TV ----------------------- #
func _process(delta):
	accumulated_time += delta

	if accumulated_time >= next_change_time:
		accumulated_time = 0.0  
		_generate_next_change_time()  
		light_tv.energy = randf_range(5,6)  

func _generate_next_change_time():
	# Générer un intervalle aléatoire entre 0.1 et 1 seconde
	next_change_time = randf_range(0.1, 0.2)

var action_to_perform = null

# ----------------------- Gestion : Boutons ----------------------- #
func _on_start_button_pressed():
	audio_player.play()
	action_to_perform = "change_scene"

func _on_exit_button_pressed():
	audio_player.play()
	action_to_perform = "quit"

# ----------------------- Gestion : Audio Boutons ----------------------- #

func _on_audio_finished():
	if action_to_perform == "change_scene":
		get_tree().change_scene_to_file("res://Scenes/LevelTransition.tscn")
	elif action_to_perform == "quit":
		get_tree().quit()
