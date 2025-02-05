extends Node2D

@onready var sprite = $Sprite2D
@onready var up_button = $UpButton
@onready var right_button = $RightButton
@onready var left_button = $LeftButton
@onready var down_button = $DownButton

var rng = RandomNumberGenerator.new()
var is_centered = false

var audio_player_cube

func _ready():
	
	audio_player_cube = AudioStreamPlayer.new()
	add_child(audio_player_cube)
	audio_player_cube.stream = load("res://Assets/Audio/Action/BeepCenterMinigame.wav")
	audio_player_cube.volume_db = -15
	
	# Connecter les signaux des boutons
	up_button.pressed.connect(move_up)
	right_button.pressed.connect(move_right)
	left_button.pressed.connect(move_left)
	down_button.pressed.connect(move_down)
	
	randomize_position()

func _process(delta):
	check_if_centered()

func randomize_position():
	var random_x = rng.randi_range(-100, 100)
	var random_y = rng.randi_range(-100, 100)
	sprite.position = Vector2(random_x, random_y)

func move_up():
	audio_player_cube.play()
	var temp = sprite.position.y - 20
	if temp >= -100:
		sprite.position.y -= 20

func move_down():
	audio_player_cube.play()
	var temp = sprite.position.y + 20
	if temp <= 100:
		sprite.position.y += 20

func move_left(): 
	audio_player_cube.play()
	var temp = sprite.position.x - 20
	if temp >= -100:
		sprite.position.x -= 20

func move_right():
	audio_player_cube.play()
	var temp = sprite.position.x + 20
	if temp <= 100:
		sprite.position.x += 20

func check_if_centered():
	var margin = 19
	var distance_to_center = sprite.position.length()
	
	if abs(sprite.position.x) <= margin and abs(sprite.position.y) <= margin:
		if not is_centered:
			print("Le sprite est centré!")
			is_centered = true
	else:
		is_centered = false
