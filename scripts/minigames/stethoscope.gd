extends Node2D

# 청진기를 배에 올려두고 3초 유지
const HOLD_TIME = 3.0
var hold_timer = 0.0
var dragging = false
var on_belly = false
var done = false

@onready var guide_label = $GuideLabel
@onready var progress_bar = $ProgressBar
@onready var progress_label = $ProgressLabel
@onready var stetho_item = $StethoscopeItem
@onready var belly_zone = $BellyZone
@onready var patient_face = $PatientChar/PatientFace

func _ready():
	progress_bar.max_value = HOLD_TIME
	progress_bar.value = 0.0
	guide_label.text = "청진기를 배에 올려두고 기다려요!"
	_play_entry_animations()

func _play_entry_animations():
	UIAnimations.fly_in_from_right(stetho_item, 150.0, 0.1)
	UIAnimations.fly_in_from_bottom(guide_label, 60.0, 0.25)

func _process(delta):
	if on_belly and not done:
		hold_timer += delta
		progress_bar.value = hold_timer
		progress_label.text = "듣는 중... 🎵"
		if hold_timer >= HOLD_TIME:
			_complete()
	elif not on_belly and not done:
		var was_holding = hold_timer > 0.5
		hold_timer = maxf(hold_timer - delta * 2.0, 0.0)
		progress_bar.value = hold_timer
		if hold_timer == 0.0:
			progress_label.text = "청진기를 배에 올려두세요"
			if was_holding:
				UIAnimations.fail_shake(guide_label)

func _input(event):
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		var pos = event.position
		if event.pressed and stetho_item.get_global_rect().has_point(pos):
			dragging = true
		elif not event.pressed:
			dragging = false
			on_belly = false

	if (event is InputEventMouseMotion or event is InputEventScreenDrag) and dragging:
		var pos = event.position
		stetho_item.global_position = pos - Vector2(150, 120)
		on_belly = belly_zone.get_global_rect().has_point(pos)
		if on_belly:
			belly_zone.color = Color(0.6, 1.0, 0.6, 0.5)
		else:
			belly_zone.color = Color(1.0, 0.8, 0.6, 0.4)

func _complete():
	if done: return
	done = true
	dragging = false
	on_belly = false
	guide_label.text = "심장 소리 잘 들었어요! ✅"
	UIAnimations.success_flash(guide_label)
	UIAnimations.celebration_pop(patient_face)
	patient_face.text = "🐰\n😌"
	progress_label.text = "💓 정상이에요!"
	_spawn_particles()
	await get_tree().create_timer(2.0).timeout
	GameManager.mark_treated("stomachache")
	SceneTransition.change_scene("res://scenes/ExamRoom.tscn")

func _spawn_particles():
	for i in range(10):
		var lbl = Label.new()
		lbl.text = ["💓", "🎵", "✨"][randi() % 3]
		lbl.add_theme_font_size_override("font_size", 48)
		lbl.position = belly_zone.position + Vector2(randf_range(-40, 40), randf_range(-40, 40))
		add_child(lbl)
		var tw = create_tween()
		tw.tween_property(lbl, "position:y", lbl.position.y - 200, 0.9)
		tw.parallel().tween_property(lbl, "modulate:a", 0.0, 0.9)
		tw.tween_callback(lbl.queue_free)

func _on_back_pressed():
	SceneTransition.change_scene("res://scenes/ExamRoom.tscn")
