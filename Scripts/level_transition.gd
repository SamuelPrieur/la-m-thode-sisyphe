extends Control

@onready var video_player = $TransitionVideo  

func _ready():
	print(Global.level)
	
	match Global.level:
		1:
			video_player.stream = preload("res://Assets/Videos/Decollage.ogv")
		2:
			video_player.stream = preload("res://Assets/Videos/Espace.ogv")
		3:
			video_player.stream = preload("res://Assets/Videos/Turbulence.ogv")
		4:
			video_player.stream = preload("res://Assets/Videos/orage.ogv")
		5:
			video_player.stream = preload("res://Assets/Videos/amerrissage.ogv")
	video_player.play()
	video_player.finished.connect(_on_video_finished)

func _on_video_finished():
	get_tree().change_scene_to_file("res://Scenes/Panel.tscn")
