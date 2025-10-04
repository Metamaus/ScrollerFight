class_name PlayerController extends CharacterBody2D

signal style_change
signal max_style_change

# Variables
@export var SPEED = 600.0
@export var JUMP_VELOCITY = 1400.0
@export var GRAVITY_MULTIPLIER = 3
@export var GRAVITY_Wall_MULTIPLIER = 2
@export var INIT_STYLE = 0

# State
@export var wallDetector : WallDetector

# Animations
@export var animationPlayer : CharacterAnimations
var shouldIdle: bool
var lastSideRight: bool
var maxStyle: int
var currentStyle: int #double jump points
var wallJump: Direction #can wall jump
enum Direction {NONE, LEFT, RIGHT, UP, DOWN}
var upJump: bool

func _ready() -> void:
	animationPlayer.play_animation(CharacterAnimations.AnimationState.IDLE, lastSideRight)
	lastSideRight = true
	wallJump = Direction.NONE
	currentStyle = INIT_STYLE
	maxStyle = INIT_STYLE
	max_style_change.emit(maxStyle)
	style_change.emit(currentStyle)

func _physics_process(delta: float) -> void:
	shouldIdle = true
	
	# Add the gravity.
	if is_on_floor():
		if(currentStyle < maxStyle):
			currentStyle = maxStyle
			style_change.emit(currentStyle)
		wallJump = Direction.NONE
	elif wallDetector.holdingWall:
		shouldIdle = false
		velocity += get_gravity() * delta * GRAVITY_Wall_MULTIPLIER
		# animationPlayer.play_animation(CharacterAnimations.AnimationState.WALL, lastSideRight)
	else:
		shouldIdle = false
		velocity += get_gravity() * delta * GRAVITY_MULTIPLIER
		animationPlayer.play_animation(CharacterAnimations.AnimationState.JUMP, lastSideRight)


	# Handle jump.
	if Input.is_action_just_pressed("jump") && try_jump():#precise enough
		shouldIdle = false
		wallDetector.holdingWall = false
		velocity = JUMP_VELOCITY * up_direction
	#todo: add salto ?
	
	#todo: add sprint for longer jumps

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("move_left", "move_right")
	if direction && !upJump:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if velocity.x > 0:
		shouldIdle = false
		lastSideRight = true
		if is_on_floor():
			animationPlayer.play_animation(CharacterAnimations.AnimationState.MOVE, lastSideRight)
	elif velocity.x < 0:
		shouldIdle = false
		lastSideRight = false
		if is_on_floor():
			animationPlayer.play_animation(CharacterAnimations.AnimationState.MOVE, lastSideRight)
	if shouldIdle: #shouldn't trigger animation every frame
		animationPlayer.play_animation(CharacterAnimations.AnimationState.IDLE, lastSideRight)
	move_and_slide()

func try_jump() -> bool:
#	todo: add speed away from the wall in this case
	if(is_on_floor()): 
		return true
	elif(wallDetector.holdingWall): # should impact jump direction ?
		var wallJumpNextDirection = is_wall_jump_allowed()
		if(wallJumpNextDirection == Direction.NONE):
			return false
		# input direction should be able to force wall jump up
		wallJump = wallJumpNextDirection
		print("WallJump")
		return true
	elif(currentStyle > 0): # should play an animation
		currentStyle = currentStyle - 1
		style_change.emit(currentStyle)
		print("DoubleJump")
		return true
	return false

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


func _on_wall_collision() -> void:
	print("Velocity y: ", velocity.y)
	if velocity.y > 0: # fine tune this
		velocity.y = 0 #todo: hold only when falling, even if we fall when already on the wall
	if velocity.y > -250:
		animationPlayer.play_animation(CharacterAnimations.AnimationState.WALL, lastSideRight)

func add_style(value: int) -> void:
	maxStyle += value
	currentStyle = maxStyle
	max_style_change.emit(maxStyle)
	style_change.emit(currentStyle)
