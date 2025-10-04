class_name CharacterVisuals extends Node2D

@export var character_animations : CharacterAnimations
@export var style_visual : Sprite2D

func _ready() -> void:
	style_visual.visible = false

func play_animation(newState: CharacterAnimations.AnimationState, lastSideRight: bool) -> void:
	character_animations.play_animation(newState, lastSideRight)

func play_multiJumpStatus(value: float) -> void:
	character_animations.play_multiJumpStatus(value)
