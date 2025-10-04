class_name CharacterAnimations extends AnimationPlayer

@export var _spriteVisual: Sprite2D
var _animationStatus: AnimationState
var _facingRight: bool
enum AnimationState {IDLE, MOVE, JUMP, WALL}

func play_animation(newState: AnimationState, lastSideRight: bool) -> void:
	_spriteVisual.flip_h = lastSideRight
	if(newState == _animationStatus && lastSideRight == _facingRight): # should check for direction
		return
	if(newState == AnimationState.IDLE):
		play("idle") # animation names could be a param
	elif(newState == AnimationState.MOVE): # should deal with starting the actions
		if(lastSideRight):
			play("move_right")
		else:
			play("move_left")
	elif(newState == AnimationState.JUMP):
		if(lastSideRight):
			play("jump_right")
		else:
			play("jump_left")
	elif(newState == AnimationState.WALL):
		if(lastSideRight):
			play("wall_right")
		else:
			play("wall_right") # TEMP
	_animationStatus = newState;
