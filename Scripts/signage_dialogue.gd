extends StaticBody2D

@export_multiline var signage_dialogue: String = ""
@onready var interactable: Area2D = $Interactable
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	interactable.interact = _on_interact

func _on_interact():
	print(signage_dialogue)
