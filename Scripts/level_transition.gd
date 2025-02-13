extends Control

@onready var video_player = $TransitionVideo  

func _ready():
	print(Global.level)
	
	match Global.level:
		1:
			video_player.stream = preload("res://Assets/Videos/Decollage.ogv")
		2:
			video_player.stream = preload("res://Assets/Videos/HyperEspace.ogv")
		3:
			video_player.stream = preload("res://Assets/Videos/Turbulences.ogv")
		4:
			video_player.stream = preload("res://Assets/Videos/Orage.ogv")
		5:
			video_player.stream = preload("res://Assets/Videos/Amerrissage.ogv")
	video_player.play()
	video_player.finished.connect(_on_video_finished)

func _on_video_finished():
	if Global.level == 5 :
		get_tree().change_scene_to_file("res://Scenes/Lose.tscn")
	else : 
		get_tree().change_scene_to_file("res://Scenes/Panel.tscn")
