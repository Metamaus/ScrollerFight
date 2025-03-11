extends CharacterBody2D

signal hit

@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0
@export var MAX_LIFE = 2
@export var equippedWeapon: Weapon

var idle = true
var lastSideRight = true
var currentLife

func _ready() -> void:
	currentLife = MAX_LIFE
	equippedWeapon.hit_enemy.connect(hitEnemy)

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
	if Input.is_action_just_pressed("base_action"): #todo: check if weapon is equipped
		equippedWeapon.playAttack(lastSideRight)
		#return ?

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

func hitEnemy(enemy_hit: Enemy) -> void:
	print("Hit!")
	enemy_hit.receiveDamage(1)
