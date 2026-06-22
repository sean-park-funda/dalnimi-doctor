extends Node2D

enum State { IDLE, MEASURING, DONE }
var state = State.IDLE
var measure_timer = 0.0
var MEASURE_TIME = 2.5

var dragging = false
var drag_offset = Vector2.ZERO
var on_forehead = false

@onready var thermometer = $Thermometer
@onready var forehead_zone = $ForeheadZone
@onready var temp_label = $TempLabel
@onready var guide_label = $GuideLabel
@onready var progress_bar = $ProgressBar

func _ready():
	temp_label.visible = false
	progress_bar.visible = false
	progress_bar.max_value = MEASURE_TIME
	guide_label.text = "체온계를 이마에 가져다 대요! 🌡️"
	_play_entry_animations()

func _play_entry_animations():
	UIAnimations.fly_in_from_right(thermometer, 160.0, 0.1)
	UIAnimations.fly_in_from_bottom(guide_label, 60.0, 0.25)

func _process(delta):
	if state == State.MEASURING:
		measure_timer += delta
		progress_bar.value = measure_timer
		if measure_timer >= MEASURE_TIME:
			_show_result()

func _on_thermometer_input(event):
	if event is InputEventScreenTouch or event is InputEventMouseButton:
		var pressed = event.pressed if event is InputEventMouseButton else event.pressed
		if pressed:
			dragging = true
			drag_offset = thermometer.global_position - get_global_mouse_position()
		else:
			dragging = false
			if not on_forehead and state == State.MEASURING:
				# 측정 중에 이마에서 뗐을 때 — 경고 피드백
				UIAnimations.fail_shake(guide_label)
			if not on_forehead:
				state = State.IDLE
				measure_timer = 0.0
				progress_bar.value = 0
				guide_label.text = "체온계를 이마에 가져다 대요! 🌡️"

func _input(event):
	if not dragging: return
	if event is InputEventMouseMotion or event is InputEventScreenDrag:
		var pos = get_global_mouse_position() if event is InputEventMouseMotion else event.position
		thermometer.global_position = pos + drag_offset
		var rect = forehead_zone.get_global_rect()
		on_forehead = rect.has_point(thermometer.global_position)
		if on_forehead and state == State.IDLE:
			state = State.MEASURING
			progress_bar.visible = true
			UIAnimations.pop_in(progress_bar)
			guide_label.text = "잠깐만요... 재는 중이에요! ⏱️"
			SoundManager.play_sfx("sfx_beep")
		elif not on_forehead and state == State.MEASURING:
			state = State.IDLE
			measure_timer = 0.0
			progress_bar.value = 0
			guide_label.text = "체온계를 이마에 가져다 대요! 🌡️"

func _show_result():
	state = State.DONE
	dragging = false
	SoundManager.play_sfx("sfx_beep")
	temp_label.visible = true
	temp_label.modulate.a = 0.0
	temp_label.text = "38.5°C\n열이 있어요! 😰"
	UIAnimations.result_pop_in(temp_label)
	guide_label.text = "잘 했어요! ✅"
	UIAnimations.success_flash(guide_label)
	_spawn_particles()
	await get_tree().create_timer(2.0).timeout
	GameManager.mark_treated("fever")
	SceneTransition.change_scene("res://scenes/ExamRoom.tscn")

func _spawn_particles():
	for i in range(12):
		var star = Label.new()
		star.text = ["⭐","✨","💫"][randi() % 3]
		star.add_theme_font_size_override("font_size", 48)
		star.position = $Thermometer.position + Vector2(randf_range(-60,60), randf_range(-60,60))
		add_child(star)
		var tw = create_tween()
		tw.tween_property(star, "position:y", star.position.y - 200, 0.8)
		tw.parallel().tween_property(star, "modulate:a", 0.0, 0.8)
		tw.tween_callback(star.queue_free)
