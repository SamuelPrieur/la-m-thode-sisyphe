extends Node

signal task_completed(task_name: String)
signal new_task_started(task_name: String)
signal task_failed(task_name: String)

var audio_player_alarm
var audio_player_button

var available_tasks = [
	# Boutons
	{"id": "Button1", "description": "Appuyer sur le bouton 1", "button_node": "Button1", "time_allowed": "5"},
	{"id": "Button2", "description": "Appuyer sur le bouton 2", "button_node": "Button2", "time_allowed": "5"},
	{"id": "Button3", "description": "Appuyer sur le bouton 3", "button_node": "Button3", "time_allowed": "5"},
	{"id": "Button4", "description": "Appuyer sur le bouton 4", "button_node": "Button4", "time_allowed": "5"},
	{"id": "Button5", "description": "Appuyer sur le bouton 5", "button_node": "Button5", "time_allowed": "5"},
	{"id": "Button6", "description": "Appuyer sur le bouton 6", "button_node": "Button6", "time_allowed": "5"},
	
	# Sliders
	{"id": "MultiTouchVSlider", "description": "Mettre le Slider 1 sur %d", "button_node": "Slider1", "possible_values": [0, 1, 2, 3], "time_allowed": "5"},
	{"id": "MultiTouchVSlider", "description": "Mettre le Slider 2 sur %d", "button_node": "Slider2", "possible_values": [0, 1, 2, 3], "time_allowed": "5"},
	{"id": "MultiTouchVSlider", "description": "Mettre le Slider 3 sur %d", "button_node": "Slider3", "possible_values": [0, 1, 2, 3], "time_allowed": "5"},
	
	#Minigames
	{"id": "OrderMinigame", "description": "Appuyer sur les boutons dans l'ordre","button_node": "OrderMinigame", "time_allowed": "300"},
	
	#Radio
	{"id": "RadioMinigame", "description": "Mettez la radio sur la fréquence %d Hz", "button_node": "RadioMinigame", "possible_values": [300,375,450,525,600,675,750,825,900], "time_allowed": "300"},
	
	#KeyPad
	#{"id": "KeyPadMinigame", "description": "Entrez le code %s", "button_node": "KeyPad", "time_allowed": "30"}
	
	
	
	
	
]

var current_task = null
var last_completed_task_id = null
var error_counter = 0
var task_timer: Timer

func _ready():
	audio_player_alarm = AudioStreamPlayer.new()
	audio_player_button = AudioStreamPlayer.new()
	add_child(audio_player_alarm)
	add_child(audio_player_button)
	audio_player_alarm.stream = load("res://Assets/Audio/Event/Alarm.wav")
	audio_player_button.stream = load("res://Assets/Audio/Action/Button.wav")
	audio_player_alarm.volume_db = -15
	audio_player_button.volume_db = -15
	
	for task in available_tasks:
		var node = get_node(task["button_node"])
		if node is MultiTouchButton:
			node.pressed.connect(_on_button_pressed.bind(task["id"]))
		elif task["id"] == "OrderMinigame" :
			continue
		elif task["id"] == "KeyPadMinigame" :
			continue
		elif task["id"] == "RadioMinigame":
			var radio_node = get_node(task["button_node"])
			radio_node.mini_game_completed.connect(_on_radio_mini_game_completed.bind(task))
		elif task["id"] == "MultiTouchVSlider":
			node.drag_ended.connect(_on_slider_drag_ended.bind(task))
	task_timer = Timer.new()
	task_timer.one_shot = true
	task_timer.timeout.connect(_on_task_timeout)
	add_child(task_timer)
	
	await get_tree().create_timer(0.1).timeout
	start_random_task()

func _on_task_timeout():
	shake_screen(3, 0.8)
	error_counter +=1
	task_failed.emit(current_task["id"])
	if error_counter < 3:
		start_random_task() 
	else:
		return
		
func change_scene_on_failure():
	get_tree().change_scene_to_file("res://Scenes/Lose.tscn")



@onready var progress_bar = $ProgressBar  # Assurez-vous d'ajouter une ProgressBar dans votre scène
var initial_time = 0.0

func orange_light():
	await get_tree().create_timer(0.5).timeout
	Global.lightState = "Hold"



# Modification de la fonction start_random_task
func start_random_task():
	orange_light()
	var available_choices = available_tasks.filter(func(task): return task["id"] != last_completed_task_id)
	current_task = available_choices[randi() % available_choices.size()]
	
	if current_task["id"] == "OrderMinigame":
		new_task_started.emit(current_task["description"])
		start_order_minigame()
		return
		
	if current_task["id"] == "KeyPadMinigame":
			# Générer un code entre 1111 et 9999 aléatoire
			current_task["target_code"] = str(randi() % 9000 + 1000)
			var keypad_node = get_node(current_task["button_node"])
			
			# Émettre le signal avec le code généré
			keypad_node.emit_signal("keypad_code_generated", current_task["target_code"])
			new_task_started.emit(current_task["description"] % current_task["target_code"])
			
			task_timer.stop()
			initial_time = float(current_task["time_allowed"])
			task_timer.wait_time = initial_time
			progress_bar.max_value = initial_time
			progress_bar.value = initial_time
			task_timer.start()
			return
	
	if "possible_values" in current_task:
		var node = get_node(current_task["button_node"])
		var current_value
		
		if current_task["id"] == "RadioMinigame":
			current_value = int(node.get_node("HzSlider").value)
			var random_value = current_task["possible_values"][randi() % current_task["possible_values"].size()]
			while random_value == current_value:
				random_value = current_task["possible_values"][randi() % current_task["possible_values"].size()]
			
			current_task["target_value"] = random_value
			node.set_target_frequency(current_task["target_value"])
		
		else:
			current_value = int(node.value)
			var random_value = current_task["possible_values"][randi() % current_task["possible_values"].size()]
			while random_value == current_value:
				random_value = current_task["possible_values"][randi() % current_task["possible_values"].size()]
			
			current_task["target_value"] = random_value
		new_task_started.emit(current_task["description"] % current_task["target_value"])
	else:
		new_task_started.emit(current_task["description"])
	
	task_timer.stop()
	initial_time = float(current_task["time_allowed"])
	task_timer.wait_time = initial_time
	progress_bar.max_value = initial_time
	progress_bar.value = initial_time
	task_timer.start()



# Ajout de la fonction de mise à jour de la barre de progression

@onready var camera = get_node("/root/Panel/Camera2D")  
var accumulated_time = 0.0

var shake_intensity = 0
var shake_duration = 0
var shake_timer = 0

func shake_screen(intensity: float, duration: float):
	shake_intensity = intensity
	shake_duration = duration
	shake_timer = duration  # Initialiser le timer à la durée de la secousse
	if shake_timer > 0:
		# Générer un déplacement aléatoire pour la secousse
		var offset_x = randf_range(-shake_intensity, shake_intensity)
		var offset_y = randf_range(-shake_intensity, shake_intensity)
		camera.offset = Vector2(offset_x, offset_y)
		
func _process(delta):
	if shake_timer > 0:
		shake_timer -= delta  # Décrémenter le timer à chaque frame
		if shake_timer <= 0:
			camera.offset = Vector2.ZERO  # Réinitialiser l'offset de la caméra lorsque le timer est écoulé
		else:
			# Appliquer un nouveau déplacement aléatoire tant que le timer n'est pas écoulé
			var offset_x = randf_range(-shake_intensity, shake_intensity)
			var offset_y = randf_range(-shake_intensity, shake_intensity)
			camera.offset = Vector2(offset_x, offset_y)
	
	if task_timer.time_left > 0:
		progress_bar.value = task_timer.time_left
		var time_ratio = task_timer.time_left / initial_time

		if time_ratio <= 0.50:
			if not audio_player_alarm.playing:
				audio_player_alarm.play()
			Global.lightState = "Error"
		else:
			audio_player_alarm.stop()


func _on_button_pressed(task_id: String):
	audio_player_button.play()
	if current_task and task_id == current_task["id"]:
		complete_current_task()

func _on_slider_drag_ended(value_changed: bool, task: Dictionary):
	if value_changed: # Si la valeur a changé pendant le drag
		var node = get_node(task["button_node"])
		var value = node.value # On récupère la valeur actuelle du slider
		if current_task and current_task["button_node"] == task["button_node"] and value == current_task["target_value"]:
			complete_current_task()
			

@onready var order_minigame_scene = preload("res://Scenes/Minigame/Order.tscn")
var order_minigame_instance = null

func start_order_minigame():
	var order_minigame = get_node("OrderMinigame")  # Le mini-jeu est déjà dans la scène
	order_minigame.mini_game_completed.connect(_on_order_minigame_completed)
	order_minigame.reset_game()
	
	task_timer.stop()
	initial_time = float(current_task["time_allowed"])
	task_timer.wait_time = initial_time
	progress_bar.max_value = initial_time
	progress_bar.value = initial_time
	task_timer.start()

# Modifiez aussi la fonction _on_order_minigame_completed :
func _on_order_minigame_completed(success: bool):
	var order_minigame = get_node("OrderMinigame")
	order_minigame.mini_game_completed.disconnect(_on_order_minigame_completed)
	
	if success:
		complete_current_task()
	else:
		error_counter += 1
		task_failed.emit(current_task["id"])
		start_random_task()


func _on_radio_mini_game_completed(success: bool, task):
	if success and current_task["id"] == task["id"]:
		complete_current_task()


func complete_current_task():
	if current_task:
		last_completed_task_id = current_task["id"]
		Global.score += 1
		Global.lightState ="Valid"
		task_completed.emit(current_task["id"])
		start_random_task()



func get_completed_tasks_count() -> int:
	return Global.score

func get_failed_tasks_count() -> int:
	return error_counter

func reset_tasks():
	Global.score = 0
	last_completed_task_id = null
	start_random_task()
