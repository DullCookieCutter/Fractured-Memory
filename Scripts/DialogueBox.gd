extends Control

@onready var text_label = $TextureRect/Label
@onready var continue_prompt = $TextureRect/Label/ContinuePrompt

func show_dialogue(message: String):
	text_label.text = ""
	self.show()
	text_label.text = message
	continue_prompt.show()
	await get_tree().create_timer(0.1).timeout
	await Input.is_action_just_pressed("interact")
	hide_dialogue()

func hide_dialogue():
	self.hide()
<<<<<<< HEAD
=======

func _ready() -> void:
	pass
	
func _process(_delta: float) -> void:
	pass
>>>>>>> 129ee4f4f9a9834257e8910df8188649eb3ff30a
