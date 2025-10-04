extends Control

@export var StyleDisplay: Label
@export var MaxStyleDisplay: Label

func _on_player_style_change(new_value: int) -> void:
	StyleDisplay.text = str(new_value)


func _on_player_max_style_change(new_value: int) -> void:
	MaxStyleDisplay.text =  "/" + str(new_value)
