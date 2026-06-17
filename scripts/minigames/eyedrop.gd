extends Node2D

# 안약을 눈 위에 가져다 대고 3번 탭하기
var drop_count = 0
const TARGET_DROPS = 3
var dragging = false
var over_eye = false

@onready var guide_label = $GuideLabel
@onready var drop_count_label = $DropCountLabel
@onready var drop_item = $EyeDropItem
@onready var eye_zone = $EyeZone
@onready var patient_face = $PatientChar/PatientFace

func _ready():
	guide_label.text = "안약을 눈 위로 가져가서 탭! (%d번)" % TARGET_DROPS
	drop_count_label.text = "0 / %d 방울" % TARGET_DROPS

func _input(event):
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		var pos = event.position
		if event.pressed:
			if drop_item.get_global_rect().has_point(pos):
				dragging = true
			# 눈 위에 있을 때 탭하면 안약 투여
			if over_eye and dragging:
				_drop_one()
		elif not event.pressed:
			dragging = false

	if (event is InputEventMouseMotion or event is InputEventScreenDrag) and dragging:
		var pos = event.position
		drop_item.global_position = pos - Vector2(150, 120)
		over_eye = eye_zone.get_global_rect().has_point(pos)
		if over_eye:
			eye_zone.color = Color(0.4, 0.7, 1.0, 0.6)
			guide_label.text = "탭! 💧"
		else:
			eye_zone.color = Color(0.6, 0.8, 1.0, 0.4)
			guide_label.text = "안약을 눈 위로 가져가서 탭!"

func _drop_one():
	drop_count += 1
	SoundManager.play_sfx("sfx_beep")
	drop_count_label.text = "%d / %d 방울" % [drop_count, TARGET_DROPS]
	_spawn_drop()
	var tw = create_tween()
	tw.tween_property(drop_item, "modulate", Color(0.5, 0.8, 1.0, 1), 0.1)
	tw.tween_property(drop_item, "modulate", Color(1, 1, 1, 1), 0.1)
	if drop_count >= TARGET_DROPS:
		_complete()

func _spawn_drop():
	var lbl = Label.new()
	lbl.text = "💧"
	lbl.add_theme_font_size_override("font_size", 40)
	lbl.position = eye_zone.position + Vector2(randf_range(0, 120), -20)
	add_child(lbl)
	var tw = create_tween()
	tw.tween_property(lbl, "position:y", lbl.position.y + 80, 0.4)
	tw.parallel().tween_property(lbl, "modulate:a", 0.0, 0.4)
	tw.tween_callback(lbl.queue_free)

func _complete():
	dragging = false
	guide_label.text = "눈이 시원해졌어요! ✅"
	patient_face.text = "🐰\n😊"
	eye_zone.color = Color(0.4, 0.9, 0.4, 0.5)
	_spawn_particles()
	await get_tree().create_timer(2.0).timeout
	GameManager.mark_treated("eye_itch")
	SceneTransition.change_scene("res://scenes/ExamRoom.tscn")

func _spawn_particles():
	for i in range(10):
		var lbl = Label.new()
		lbl.text = ["💧", "✨", "🌟"][randi() % 3]
		lbl.add_theme_font_size_override("font_size", 44)
		lbl.position = eye_zone.position + Vector2(randf_range(-40, 40), randf_range(-20, 20))
		add_child(lbl)
		var tw = create_tween()
		tw.tween_property(lbl, "position:y", lbl.position.y - 180, 0.8)
		tw.parallel().tween_property(lbl, "modulate:a", 0.0, 0.8)
		tw.tween_callback(lbl.queue_free)

func _on_back_pressed():
	SceneTransition.change_scene("res://scenes/ExamRoom.tscn")
