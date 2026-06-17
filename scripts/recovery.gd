extends Node2D

const PRAISE = [
	"와! 최고 의사선생님! 🎉",
	"달토끼가 이제 안 아파요! 💖",
	"너무 잘했어요! 👏",
	"훌륭한 의사선생님이에요! ⭐",
]

func _ready():
	GameManager.complete_treatment()
	SoundManager.play_sfx("sfx_success")
	$PraiseLabel.text = PRAISE[randi() % PRAISE.size()]
	_animate_character()
	_spawn_celebration()

func _animate_character():
	var tw = create_tween()
	tw.tween_property($PatientChar, "position:y", 700.0, 0.4).set_ease(Tween.EASE_OUT)
	tw.tween_property($PatientChar, "position:y", 760.0, 0.2).set_ease(Tween.EASE_IN)
	tw.tween_property($PatientChar, "position:y", 720.0, 0.3).set_ease(Tween.EASE_OUT)

func _spawn_celebration():
	for i in range(20):
		await get_tree().create_timer(randf_range(0.0, 1.5)).timeout
		var emoji = ["⭐","💖","✨","🎉","🌟","💫"][randi() % 6]
		var lbl = Label.new()
		lbl.text = emoji
		lbl.theme_override_font_sizes["font_size"] = 64
		lbl.position = Vector2(randf_range(80, 1000), 1920)
		add_child(lbl)
		var tw = create_tween()
		tw.tween_property(lbl, "position:y", randf_range(200, 800), 1.5).set_ease(Tween.EASE_OUT)
		tw.parallel().tween_property(lbl, "modulate:a", 0.0, 1.5)
		tw.tween_callback(lbl.queue_free)

func _on_continue_pressed():
	SoundManager.play_sfx("sfx_click")
	SceneTransition.change_scene("res://scenes/StickerBook.tscn")

func _on_retry_pressed():
	SoundManager.play_sfx("sfx_click")
	SceneTransition.change_scene("res://scenes/PatientSelect.tscn")
