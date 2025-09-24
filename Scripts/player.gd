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
var wallJump: Direction #can wall jump
enum Direction {NONE, LEFT, RIGHT, UP, DOWN}

func _ready() -> void:
	play_animation(AnimationState.IDLE)
	lastSideRight = true
	wallJump = Direction.NONE
	currentStyle = INIT_STYLE
	style_change.emit(currentStyle)

func _physics_process(delta: float) -> void:
	shouldIdle = true
	
	# Add the gravity.
	if not is_on_floor():
		shouldIdle = false
		velocity += get_gravity() * delta * GRAVITY_MULTIPLIER
		play_animation(AnimationState.JUMP)
	else:
		if(currentStyle < INIT_STYLE):
			currentStyle = INIT_STYLE
			style_change.emit(currentStyle)
		wallJump = Direction.NONE

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
	if(is_on_floor()): 
		return true
	elif(is_on_wall()): # should impact jump direction
		var wallJumpNextDirection = is_wall_jump_allowed()
		if(wallJumpNextDirection == Direction.NONE):
			return false
		# input direction should be able to force wall jump up
		wallJump = wallJumpNextDirection
		return true
	elif(currentStyle > 0): # should play an animation
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

func is_wall_jump_allowed() -> Direction: # return new direction if valide, NONE if invalid
	if(wallJump == Direction.UP):
		return Direction.NONE
	var wallJumpNormal = normal_to_direction(get_wall_normal())
	if(wallJump != wallJumpNormal):
		return wallJumpNormal
	return Direction.NONE

func normal_to_direction(normal : Vector2) -> Direction:
	var angle = normal.angle_to(Vector2.RIGHT)
	if(abs(angle) > 0.75*PI):
		return Direction.LEFT
	if(abs(angle) < 0.25*PI):
		return Direction.RIGHT
	if(angle > 0):
		return Direction.UP
	if(angle < 0 ):
		return Direction.DOWN
	return Direction.NONE
