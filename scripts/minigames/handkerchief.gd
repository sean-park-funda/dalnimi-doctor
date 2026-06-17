extends Node2D

# 손수건으로 코를 위→아래로 3번 닦기
var swipe_count = 0
const TARGET_SWIPES = 3
var dragging = false
var swipe_start_y = 0.0
var was_on_nose = false

@onready var guide_label = $GuideLabel
@onready var progress_label = $ProgressLabel
@onready var hk_item = $HandkerchiefItem
@onready var nose_zone = $NoseZone
@onready var patient_face = $PatientChar/PatientFace

func _ready():
	guide_label.text = "손수건으로 코를 닦아줘요! (위→아래 %d번)" % TARGET_SWIPES
	progress_label.text = "0 / %d" % TARGET_SWIPES

func _input(event):
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		var pos = event.position
		if event.pressed and hk_item.get_global_rect().has_point(pos):
			dragging = true
			swipe_start_y = pos.y
		elif not event.pressed:
			dragging = false

	if (event is InputEventMouseMotion or event is InputEventScreenDrag) and dragging:
		var pos = event.position
		hk_item.global_position = pos - Vector2(150, 110)
		if nose_zone.get_global_rect().has_point(pos):
			if not was_on_nose:
				# 코 영역 진입 시 기준점 리셋 (아래서 드래그해 올라올 때 dy 오계산 방지)
				swipe_start_y = pos.y
				was_on_nose = true
			var dy = pos.y - swipe_start_y
			if dy > 60:
				swipe_count += 1
				swipe_start_y = pos.y
				_on_swipe()
		else:
			was_on_nose = false

func _on_swipe():
	SoundManager.play_sfx("sfx_brush")
	progress_label.text = "%d / %d" % [swipe_count, TARGET_SWIPES]
	nose_zone.color = Color(0.6 + swipe_count * 0.1, 1.0, 0.6, 0.5)
	var tw = create_tween()
	tw.tween_property(hk_item, "modulate", Color(1, 1, 0.5, 1), 0.08)
	tw.tween_property(hk_item, "modulate", Color(1, 1, 1, 1), 0.08)
	if swipe_count >= TARGET_SWIPES:
		_complete()

func _complete():
	dragging = false
	guide_label.text = "깨끗해졌어요! ✅"
	patient_face.text = "🐰\n😊"
	_spawn_particles()
	await get_tree().create_timer(2.0).timeout
	GameManager.mark_treated("runny_nose")
	SceneTransition.change_scene("res://scenes/ExamRoom.tscn")

func _spawn_particles():
	for i in range(10):
		var lbl = Label.new()
		lbl.text = ["✨", "💨", "🌟"][randi() % 3]
		lbl.add_theme_font_size_override("font_size", 48)
		lbl.position = nose_zone.position + Vector2(randf_range(-40, 40), randf_range(-40, 40))
		add_child(lbl)
		var tw = create_tween()
		tw.tween_property(lbl, "position:y", lbl.position.y - 200, 0.8)
		tw.parallel().tween_property(lbl, "modulate:a", 0.0, 0.8)
		tw.tween_callback(lbl.queue_free)

func _on_back_pressed():
	SceneTransition.change_scene("res://scenes/ExamRoom.tscn")
