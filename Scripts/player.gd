extends CharacterBody2D

signal hit

@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0
@export var MAX_LIFE = 2
@export var equippedWeapon: Weapon
@export var animations: AnimationPlayer

var idle: bool
var shouldIdle: bool
var lastSideRight: bool
var currentLife: int

func _ready() -> void:
	idle = false
	lastSideRight = true
	currentLife = MAX_LIFE
	equippedWeapon.hit_enemy.connect(hitEnemy)

func _physics_process(delta: float) -> void:
	shouldIdle = true
	
	# Add the gravity.
	if not is_on_floor():
		shouldIdle = false
		velocity += get_gravity() * delta
		if lastSideRight:
			animations.play("jump_right")
		else:
			animations.play("jump_left")

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		shouldIdle = false
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
		shouldIdle = false
		idle = false
		lastSideRight = true
		animations.play("move_right")
	elif velocity.x < 0:
		shouldIdle = false
		idle = false
		lastSideRight = false
		animations.play("move_left")
	if shouldIdle and !idle: #shouldn't trigger animation every frame
		if lastSideRight:
			animations.play("idle_right")
		else:
			animations.play("idle_left")
		idle = true
	move_and_slide()

func hitEnemy(enemy_hit: Enemy) -> void:
	print("Hit!")
	enemy_hit.receiveDamage(1)
