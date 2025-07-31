extends Control

@export var StyleDisplay: Label

func _on_player_style_change(new_value: int) -> void:
	StyleDisplay.text = str(new_value)
