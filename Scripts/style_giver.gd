extends Node2D

@export var timer : Timer
@export var timerDuration : float = 1
@export var styleIncrease : int = 1

var player : PlayerController
var increaseGiven : bool

func _ready() -> void:
	increaseGiven = false

func _on_area_2d_body_entered(body: Node2D) -> void: #weird to need to connect in every scene
	if body is PlayerController && !increaseGiven:
		timer.start(timerDuration)
		player = body


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is PlayerController && !increaseGiven:
		timer.stop()
		player = null


func _on_timer_timeout() -> void:
	increaseGiven = true
	timer.stop()
	player.add_style(styleIncrease)
