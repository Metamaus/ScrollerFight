class_name WallDetector extends Node2D

signal wall_collision

var holdingWall: bool # jump set this to false because the character detach from the wall
var onLeftWall: bool
var onRightWall: bool

func _on_area_2_dleft_body_entered(_body: Node2D) -> void:
	wall_collision.emit()
	onLeftWall = true
	holdingWall = true


func _on_area_2_dleft_body_exited(_body: Node2D) -> void:
	onLeftWall = false
	holdingWall = false


func _on_area_2_dright_body_entered(_body: Node2D) -> void:
	wall_collision.emit()
	onRightWall = true
	holdingWall = true
	pass # Replace with function body.


func _on_area_2_dright_body_exited(_body: Node2D) -> void:
	onRightWall = false
	holdingWall = false
	pass # Replace with function body.
