extends Node

var score: int = 0
var level: int = 1
var lightState: String = "Hold"
var current_task: Dictionary
var last_completed_task: String
var error_counter: int = 0

var reactorState = "Éteint"
var ventilateur = "off"