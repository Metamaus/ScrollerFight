extends CharacterBody2D

signal style_change

@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0
@export var MAX_LIFE = 2
@export var INIT_STYLE = 1
#@export var equippedWeapon: Weapon
@export var animations: AnimationPlayer

var idle: bool
var shouldIdle: bool
var lastSideRight: bool
var currentLife: int
var currentStyle: int

func _ready() -> void:
	idle = false
	lastSideRight = true
	currentLife = MAX_LIFE
	currentStyle = INIT_STYLE
	style_change.emit(currentStyle)
	#equippedWeapon.hit_enemy.connect(hitEnemy)

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
	elif currentStyle < INIT_STYLE:
		currentStyle += 1
		style_change.emit(currentStyle)

	# Handle jump.
	if Input.is_action_just_pressed("jump") and try_jump():
		shouldIdle = false
		idle = false
		velocity.y = JUMP_VELOCITY
	#if Input.is_action_just_pressed("base_action"): #todo: add salto ?
		#equippedWeapon.playAttack(lastSideRight)
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

#func hitEnemy(enemy_hit: Enemy) -> void:
	#print("Hit!")
	#enemy_hit.receiveDamage(1)

func try_jump() -> bool:
#	todo: add speed away from the wall in this case
	if(is_on_floor()): 
		return true
	elif(currentStyle > 0):
		currentStyle = currentStyle - 1
		style_change.emit(currentStyle)
		return true
	return false
