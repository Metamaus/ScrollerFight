class_name Weapon

extends Node2D

signal hit_enemy(enemy_hit: Enemy)

@export var WeaponAnimations: AnimationPlayer
var enemyHit: Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func playAttack(faceRight: bool):
	if(faceRight):
		WeaponAnimations.play("attack_right")
	else:
		WeaponAnimations.play("attack_left")
	enemyHit.clear()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Enemy and (enemyHit.find(body) < 0) :
		hit_enemy.emit(body)
		enemyHit.append(body)
