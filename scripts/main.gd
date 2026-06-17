extends Node2D

func _ready():
	SoundManager.play_bgm("bgm_main")
	_play_entry_animations()
	UIAnimations.connect_buttons(self)

func _play_entry_animations():
	$Title.modulate.a = 0.0
	$Subtitle.modulate.a = 0.0
	$DoctorChar.modulate.a = 0.0
	$StartButton.modulate.a = 0.0
	$StickerButton.modulate.a = 0.0
	$StartButton.scale = Vector2.ZERO
	$StickerButton.scale = Vector2.ZERO

	UIAnimations.fly_in_from_top($Title, 60.0, 0.1)
	UIAnimations.fly_in_from_right($DoctorChar, 220.0, 0.25)
	UIAnimations.fly_in_from_bottom($Subtitle, 40.0, 0.4)
	UIAnimations.pop_in($StartButton, 0.55)
	UIAnimations.pop_in($StickerButton, 0.68)

	# 캐릭터 등장 후 float bob 시작
	await get_tree().create_timer(0.85).timeout
	UIAnimations.float_bob($DoctorChar, 10.0, 2.2)

func _on_start_button_pressed():
	SoundManager.play_sfx("sfx_click")
	SceneTransition.change_scene("res://scenes/PatientSelect.tscn")

func _on_sticker_button_pressed():
	SoundManager.play_sfx("sfx_click")
	SceneTransition.change_scene("res://scenes/StickerBook.tscn")
