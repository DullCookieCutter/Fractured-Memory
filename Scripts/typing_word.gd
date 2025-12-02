extends Area2D

@export var word_to_type: String = ""
@export var speed: float = 100.0
@export var target_position: Vector2 = Vector2.ZERO

var direction: Vector2 = Vector2.ZERO
var typed_substring: String = ""
@onready var word_label: RichTextLabel = $Label

signal target_hit(word_node)

func _ready():
	word_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	update_visuals() 
	add_to_group("words")

func setup_movement():
	direction = (target_position - global_position).normalized()

# --- Game Loop ---
func _process(delta: float) -> void:
	global_position += direction * speed * delta

# --- Collision Handling ---
func _on_typing_word_area_entered(area: Area2D):
	if area.is_in_group("target"):
		target_hit.emit(self)
		queue_free()

# --- Visuals ---
func update_visuals():
	var typed_len = typed_substring.length()
	var remaining_text = word_to_type.substr(typed_len)
	var typed_text = word_to_type.substr(0, typed_len)
	
	var typed_bbcode = "[color=#00FF00]" + typed_text + "[/color]"
	var remaining_bbcode = "[color=#FFFF00]" + remaining_text + "[/color]"
	
	word_label.clear()
	word_label.append_text(typed_bbcode + remaining_bbcode)
