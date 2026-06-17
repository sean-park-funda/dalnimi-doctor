extends Node2D

func _ready():
	SoundManager.play_bgm("bgm_main")
	# 달님이 캐릭터 bounce 애니메이션
	var tween = create_tween().set_loops()
	tween.tween_property($DoctorChar, "position:y", 860.0, 0.6).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($DoctorChar, "position:y", 880.0, 0.6).set_ease(Tween.EASE_IN_OUT)

func _on_start_button_pressed():
	SoundManager.play_sfx("sfx_click")
	SceneTransition.change_scene("res://scenes/PatientSelect.tscn")

func _on_sticker_button_pressed():
	SoundManager.play_sfx("sfx_click")
	SceneTransition.change_scene("res://scenes/StickerBook.tscn")
