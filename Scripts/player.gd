extends CharacterBody2D

signal style_change

@export var SPEED = 300.0
@export var JUMP_VELOCITY = -400.0
@export var GRAVITY_MULTIPLIER = 3
@export var INIT_STYLE = 1

# Animations
@export var animations: AnimationPlayer
@export var spriteVisual: Sprite2D
enum AnimationState {IDLE, MOVE, JUMP}

var animationStatus: AnimationState
var shouldIdle: bool
var lastSideRight: bool
var currentStyle: int #double jump points

func _ready() -> void:
	play_animation(AnimationState.IDLE)
	lastSideRight = true
	#currentLife = MAX_LIFE
	currentStyle = INIT_STYLE
	style_change.emit(currentStyle)
	#equippedWeapon.hit_enemy.connect(hitEnemy)

func _physics_process(delta: float) -> void:
	shouldIdle = true
	
	# Add the gravity.
	if not is_on_floor():
		shouldIdle = false
		velocity += get_gravity() * delta * GRAVITY_MULTIPLIER
		play_animation(AnimationState.JUMP)
	elif currentStyle < INIT_STYLE:
		currentStyle += 1
		style_change.emit(currentStyle)

	# Handle jump.
	if Input.is_action_just_pressed("jump") and try_jump():
		shouldIdle = false
		velocity.y = JUMP_VELOCITY
	#todo: add salto ?
	
	#todo: add sprint for longer jumps

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if velocity.x > 0:
		shouldIdle = false
		lastSideRight = true
		if is_on_floor():
			play_animation(AnimationState.MOVE)
	elif velocity.x < 0:
		shouldIdle = false
		lastSideRight = false
		if is_on_floor():
			play_animation(AnimationState.MOVE)
	if shouldIdle and animationStatus != AnimationState.IDLE: #shouldn't trigger animation every frame
		play_animation(AnimationState.IDLE)
	move_and_slide()

func try_jump() -> bool:
#	todo: add speed away from the wall in this case
	if(is_on_floor() || is_on_wall()): 
		return true
	elif(currentStyle > 0):
		currentStyle = currentStyle - 1
		style_change.emit(currentStyle)
		return true
	return false

func play_animation(newState: AnimationState) -> void:
	spriteVisual.flip_h = lastSideRight
	if(newState == animationStatus): # should check for direction
		return
	if(newState == AnimationState.IDLE):
		animations.play("idle") # animation names could be a param
	elif(newState == AnimationState.MOVE): # should deal with starting the actions
		if(lastSideRight):
			animations.play("move_right")
		else:
			animations.play("move_left")
	elif(newState == AnimationState.JUMP):
		if(lastSideRight):
			animations.play("jump_right")
		else:
			animations.play("jump_left")
	animationStatus = newState;
