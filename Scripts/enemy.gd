class_name Enemy

extends RigidBody2D

@export var max_life: int = 2
var current_life: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_life = max_life

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func receiveDamage(damage: int):
	current_life -= damage
	if(current_life <= 0):
		die()

func die():
	queue_free()
