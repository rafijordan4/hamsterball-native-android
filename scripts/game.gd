extends Node3D

# Original prototype: rolling physics, a simple obstacle course, and touch controls.
# No original Hamsterball executable or copyrighted game assets are embedded.

var ball: RigidBody3D
var camera: Camera3D
var status_label: Label
var left_held := false
var right_held := false
var forward_held := false
var back_held := false
var finished := false
var start_position := Vector3(0, 2.2, 7)
var course_end_z := -43.0

func _ready() -> void:
	_build_world()
	_build_course()
	_build_ball()
	_build_camera()
	_build_ui()

func _physics_process(_delta: float) -> void:
	if ball == null:
		return
	if not finished:
		var input_dir := Vector3.ZERO
		if left_held or Input.is_action_pressed("ui_left"):
			input_dir.x -= 1.0
		if right_held or Input.is_action_pressed("ui_right"):
			input_dir.x += 1.0
		if forward_held or Input.is_action_pressed("ui_up"):
			input_dir.z -= 1.0
		if back_held or Input.is_action_pressed("ui_down"):
			input_dir.z += 1.0
		if input_dir.length() > 0.01:
			input_dir = input_dir.normalized()
			ball.apply_central_force(Vector3(input_dir.x * 34.0, 0.0, input_dir.z * 34.0))
			# Add a gentle visual spin so the sphere reads as rolling.
			ball.apply_torque(Vector3(input_dir.z * 8.0, 0.0, -input_dir.x * 8.0))
		if ball.global_position.y < -8.0:
			_reset_ball()
		if ball.global_position.z <= course_end_z:
			finished = true
			status_label.text = "FINISH! Tap RESET to play again"
			status_label.add_theme_color_override("font_color", Color(0.45, 1.0, 0.65))
		elif status_label != null:
			status_label.text = "Reach the green finish gate  |  WASD / arrows or touch controls"

func _build_world() -> void:
	var env := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.72, 0.78, 0.9)
	environment.ambient_light_energy = 0.8
	env.environment = environment
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48, -28, 0)
	sun.light_energy = 1.2
	add_child(sun)

func _build_course() -> void:
	# Start platform and straight track.
	_add_platform(Vector3(0, 0, 5), Vector3(9, 1, 12), Color(0.28, 0.34, 0.43))
	_add_platform(Vector3(0, 0, -7), Vector3(5.5, 1, 17), Color(0.36, 0.42, 0.5))
	# Narrow bridge section.
	_add_platform(Vector3(0, 0, -20), Vector3(3.4, 0.65, 10), Color(0.68, 0.55, 0.31))
	# Wide landing and final path.
	_add_platform(Vector3(0, 0, -29), Vector3(7.5, 1, 8), Color(0.28, 0.34, 0.43))
	_add_platform(Vector3(0, 0, -38), Vector3(5.0, 1, 12), Color(0.36, 0.42, 0.5))
	# Side rails to help beginners stay on the course.
	_add_platform(Vector3(-2.8, 0.7, -7), Vector3(0.25, 1.4, 17), Color(0.82, 0.84, 0.88))
	_add_platform(Vector3(2.8, 0.7, -7), Vector3(0.25, 1.4, 17), Color(0.82, 0.84, 0.88))
	_add_platform(Vector3(-1.85, 0.55, -20), Vector3(0.18, 1.1, 10), Color(0.9, 0.72, 0.38))
	_add_platform(Vector3(1.85, 0.55, -20), Vector3(0.18, 1.1, 10), Color(0.9, 0.72, 0.38))
	# Simple bumper obstacles.
	_add_obstacle(Vector3(-1.0, 0.9, -5.0), Vector3(0.8, 1.8, 0.8), Color(0.86, 0.38, 0.28))
	_add_obstacle(Vector3(1.0, 0.9, -10.0), Vector3(0.8, 1.8, 0.8), Color(0.86, 0.38, 0.28))
	_add_obstacle(Vector3(0.0, 0.8, -30.0), Vector3(1.0, 1.6, 0.8), Color(0.86, 0.38, 0.28))
	# Finish gate marker.
	_add_obstacle(Vector3(-1.7, 1.5, course_end_z), Vector3(0.22, 3.0, 0.25), Color(0.2, 0.9, 0.48))
	_add_obstacle(Vector3(1.7, 1.5, course_end_z), Vector3(0.22, 3.0, 0.25), Color(0.2, 0.9, 0.48))
	_add_obstacle(Vector3(0, 3.0, course_end_z), Vector3(3.6, 0.22, 0.25), Color(0.2, 0.9, 0.48))

func _add_platform(pos: Vector3, size: Vector3, color: Color) -> void:
	var body := StaticBody3D.new()
	body.position = pos
	var mesh := BoxMesh.new()
	mesh.size = size
	var visual := MeshInstance3D.new()
	visual.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.8
	visual.material_override = material
	body.add_child(visual)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	body.add_child(shape)
	add_child(body)

func _add_obstacle(pos: Vector3, size: Vector3, color: Color) -> void:
	_add_platform(pos, size, color)

func _build_ball() -> void:
	ball = RigidBody3D.new()
	ball.name = "PlayerBall"
	ball.position = start_position
	ball.mass = 1.0
	ball.continuous_cd = true
	ball.linear_damp = 0.25
	ball.angular_damp = 0.15
	ball.physics_material_override = PhysicsMaterial.new()
	ball.physics_material_override.bounce = 0.12
	ball.physics_material_override.friction = 0.8
	var sphere := SphereMesh.new()
	sphere.radius = 0.72
	sphere.height = 1.44
	var visual := MeshInstance3D.new()
	visual.mesh = sphere
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.95, 0.72, 0.24)
	mat.metallic = 0.15
	mat.roughness = 0.24
	visual.material_override = mat
	ball.add_child(visual)
	var collision := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = 0.72
	collision.shape = shape
	ball.add_child(collision)
	add_child(ball)

func _build_camera() -> void:
	camera = Camera3D.new()
	camera.position = Vector3(0, 5.5, 9)
	camera.rotation_degrees = Vector3(-20, 0, 0)
	camera.current = true
	add_child(camera)

func _process(delta: float) -> void:
	if ball != null and camera != null:
		var desired := ball.global_position + Vector3(0, 5.0, 8.0)
		camera.global_position = camera.global_position.lerp(desired, min(delta * 3.0, 1.0))
		camera.look_at(ball.global_position + Vector3(0, 0.5, -2.0), Vector3.UP)

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(root)
	status_label = Label.new()
	status_label.text = "Reach the green finish gate  |  WASD / arrows or touch controls"
	status_label.position = Vector2(20, 16)
	status_label.size = Vector2(1000, 42)
	status_label.add_theme_font_size_override("font_size", 20)
	status_label.add_theme_color_override("font_color", Color(1, 1, 1))
	root.add_child(status_label)
	_add_hold_button(root, "LEFT", Vector2(24, -118), Vector2(88, 76), "left")
	_add_hold_button(root, "RIGHT", Vector2(216, -118), Vector2(88, 76), "right")
	_add_hold_button(root, "FORWARD", Vector2(120, -196), Vector2(88, 76), "forward")
	_add_hold_button(root, "BACK", Vector2(120, -40), Vector2(88, 76), "back")
	var reset := Button.new()
	reset.text = "RESET"
	reset.anchor_left = 1.0
	reset.anchor_right = 1.0
	reset.offset_left = -130
	reset.offset_right = -20
	reset.offset_top = 20
	reset.offset_bottom = 68
	reset.pressed.connect(_reset_ball)
	root.add_child(reset)

func _add_hold_button(parent: Control, caption: String, offset: Vector2, button_size: Vector2, action: String) -> void:
	var b := Button.new()
	b.text = caption
	b.size = button_size
	b.anchor_left = 0.0
	b.anchor_right = 0.0
	b.anchor_top = 1.0
	b.anchor_bottom = 1.0
	b.offset_left = offset.x
	b.offset_right = offset.x + button_size.x
	b.offset_top = offset.y
	b.offset_bottom = offset.y + button_size.y
	b.add_theme_font_size_override("font_size", 16)
	b.button_down.connect(func(): _set_held(action, true))
	b.button_up.connect(func(): _set_held(action, false))
	parent.add_child(b)

func _set_held(action: String, value: bool) -> void:
	match action:
		"left": left_held = value
		"right": right_held = value
		"forward": forward_held = value
		"back": back_held = value

func _reset_ball() -> void:
	if ball == null:
		return
	ball.global_position = start_position
	ball.linear_velocity = Vector3.ZERO
	ball.angular_velocity = Vector3.ZERO
	finished = false
	if status_label != null:
		status_label.text = "Reach the green finish gate  |  WASD / arrows or touch controls"
		status_label.remove_theme_color_override("font_color")
