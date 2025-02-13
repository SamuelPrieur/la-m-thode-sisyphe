extends Node2D

@export var amplitude: float = 25.0 
@export var frequency: float = 1.0 
@export var speed: float = 8.0  
@export var points_count: int = 500 

var time: float = 0.0
@onready var line: Line2D = $Line2D
@onready var changeCurveButton: TextureButton = $ChangeCurve
@onready var changeColorButton: TextureButton = $ChangeColor

enum CurveType { SIN, M, SQUARE }
var current_curve: int = CurveType.SIN
var current_color: Color = Color(1, 1, 0)

func _ready():
	changeCurveButton.pressed.connect(_on_curve_button_pressed)
	changeColorButton.pressed.connect(_on_color_button_pressed)

func _process(delta):
	time += delta * speed
	var new_points = []
	
	for i in range(points_count):
		var t = float(i) / float(points_count - 1)
		var x = t * 400.0
		var y = 0.0
		
		match current_curve:
			CurveType.SIN:
				y = amplitude * sin(frequency * x * 0.05 + time)
			CurveType.M:
				var wave = sin(frequency * x * 0.05 + time)
				y = amplitude * (3 * wave - 2 * wave * wave * wave)  
			CurveType.SQUARE:
				y = amplitude * (1 if sin(frequency * x * 0.05 + time) > 0 else -1)
		
		new_points.append(Vector2(x, y))
	
	line.points = new_points
	line.default_color = current_color 

func _on_curve_button_pressed():
	current_curve = (current_curve + 1) % CurveType.size()

func _on_color_button_pressed():
	if current_color == Color(1,1,0):
		current_color = Color(0, 1, 1)  
	elif current_color == Color(0, 1, 1) :
		current_color = Color(0, 1, 0)  
	else:
		current_color = Color(1, 1, 0)  
