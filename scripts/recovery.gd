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
	# 초기 숨김
	$Title.modulate.a = 0.0
	$PraiseLabel.modulate.a = 0.0
	$ContinueButton.modulate.a = 0.0
	$RetryButton.modulate.a = 0.0
	$ContinueButton.scale = Vector2.ZERO
	$RetryButton.scale = Vector2.ZERO
	UIAnimations.connect_buttons(self)
	_play_entry_animations()
	_spawn_celebration()

func _play_entry_animations():
	# "완치!" 타이틀 bounce 착지
	UIAnimations.title_drop($Title, 100.0, 0.0)
	# 환자 캐릭터 squash & stretch 점프
	UIAnimations.celebration_pop($PatientChar, 0.2)
	# float bob 시작 (0.7초 후)
	get_tree().create_timer(0.7).timeout.connect(func():
		UIAnimations.float_bob($PatientChar, 12.0, 1.8))
	# 칭찬 텍스트
	UIAnimations.fly_in_from_bottom($PraiseLabel, 50.0, 0.4)
	# 버튼들 순서대로 pop-in
	UIAnimations.pop_in($ContinueButton, 0.6)
	UIAnimations.pop_in($RetryButton, 0.72)

func _spawn_celebration():
	for i in range(20):
		await get_tree().create_timer(randf_range(0.0, 1.5)).timeout
		var emoji = ["⭐","💖","✨","🎉","🌟","💫"][randi() % 6]
		var lbl = Label.new()
		lbl.text = emoji
		lbl.add_theme_font_size_override("font_size", 64)
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
