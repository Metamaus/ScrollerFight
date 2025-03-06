extends CharacterBody2D

signal hit

@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0
@export var MAX_LIFE = 2
var idle = true
var lastSideRight = true
var currentLife

func _ready() -> void:
	currentLife = MAX_LIFE

func _physics_process(delta: float) -> void:
	idle = true
	
	# Add the gravity.
	if not is_on_floor():
		idle = false
		velocity += get_gravity() * delta
		if lastSideRight:
			$AnimatedSprite2D.animation = "jump-right"
		else:
			$AnimatedSprite2D.animation = "jump-left"

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		idle = false
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if velocity.x > 0:
		idle = false
		lastSideRight = true
		$AnimatedSprite2D.animation = "run-right"
	elif velocity.x < 0:
		idle = false
		lastSideRight = false
		$AnimatedSprite2D.animation = "run-left"
	if idle:
		if lastSideRight:
			$AnimatedSprite2D.animation = "idle-right"
		else:
			$AnimatedSprite2D.animation = "idle-left"
	$AnimatedSprite2D.play()
	move_and_slide()
