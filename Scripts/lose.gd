extends Node2D

var score = 0
@onready var score_label = $ScoreLabel
@onready var explosion = $Explosion
@onready var exit_button = $ExitButton
var audio_player_lose

# Liste des fichiers audio
var audio_files = [
	"res://Assets/Audio/Event/DeathCrash1.wav",
	"res://Assets/Audio/Event/DeathCrash3.wav"
]

func _ready():
	audio_player_lose = AudioStreamPlayer.new()
	add_child(audio_player_lose)

	# Sélectionne un fichier aléatoire
	var random_audio = audio_files[randi() % audio_files.size()]
	audio_player_lose.stream = load(random_audio)
	audio_player_lose.volume_db = -15
	audio_player_lose.play()
	
	explosion.animation_finished.connect(_on_animation_finished)
	score_label.hide()
	update_score()
	
	exit_button.pressed.connect(_on_exit_button_pressed)

func _on_animation_finished():
	score_label.show()

func update_score():
	score_label.text = "Score: " + str(Global.score)

func _on_exit_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/StartMenu.tscn")
