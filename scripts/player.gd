extends CharacterBody3D

@onready var camera = $eyes/Camera3D
@onready var eyes = $eyes

## Movement
# Speed variables
var SPEED := 5.0
const WALKING_SPEED := 9.0
const SPRINT_SPEED := 12.0
const BACKWARDS_SPEED := 5.0
const JUMP_VELOCITY := 4.5

# Direction global variable
var direction := Vector3.ZERO
# Lerp speed for smooth movement
var lerp_speed := 10
# Stamina variables, not final numbers!
var stamina_max := 100.
var stamina := 100.
var jump_stamina_consumption := 11.
var sprinting_stamina_consumption := 0.5
var stamina_wait_time := 2.
var stamina_cooldown := 0.
# Mouse sensitivies
var mouse_sens := 0.25
var jumping_mouse_sens := 0.05
## Headbobbing
# Values
const headbobbing_values := {"Intensity" : {"walking" : 0.1, "sprinting" : 0.2, "none" : 0.0},
	"Speed" : {"walking" : 14.0, "sprinting" : 22.0, "none" : 0.0},}
# Variables
var headbobbing_vector := Vector2.ZERO
var headbobbing_index := 0.0
var headbobbing_current_intensity := 0.0


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Looking and setting direction by mouse.
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Normal sensitivity when is player on floor.
		if is_on_floor():
			rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
			camera.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89), deg_to_rad(89))
		# Slower sensitivity when is player in air.
		else:
			rotate_y(deg_to_rad(-event.relative.x * jumping_mouse_sens))
			camera.rotate_x(deg_to_rad(-event.relative.y * jumping_mouse_sens))
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89), deg_to_rad(89))

## Stamina functions
func use_stamina(stamina_decrease) -> void:
	stamina -= stamina_decrease
	stamina_cooldown = stamina_wait_time
func regenerate_stamina() -> void:
	if stamina < stamina_max:
		stamina += 1

## Headbobbing functions

# Headbobbing intensity and speed values setting
func set_headbobbing_values(delta: float, current_movement) -> void:
	headbobbing_current_intensity = headbobbing_values["Intensity"][current_movement]
	headbobbing_index += headbobbing_values["Speed"][current_movement] * delta

# Headbobbing vector setting
func set_headbobbing_vector() -> void:
	headbobbing_vector.y = sin(headbobbing_index)
	headbobbing_vector.x = sin(headbobbing_index / 2) + 0.5

# Headbobbing eyes position setting
func set_headbobbing_eyes_position(delta: float) -> void:
	eyes.position.y = lerp(eyes.position.y, headbobbing_vector.y * (headbobbing_current_intensity / 2.0), delta * lerp_speed)
	eyes.position.x = lerp(eyes.position.x, headbobbing_vector.x * headbobbing_current_intensity, delta * lerp_speed)

# Headbobbing master function combining all functions of headbobbing.
func headbobbing(delta: float, current_movement) -> void:
	set_headbobbing_values(delta, current_movement)
	set_headbobbing_vector()
	set_headbobbing_eyes_position(delta)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Stamina cooldown lowering.
	if stamina_cooldown > 0.:
		stamina_cooldown -= delta

	# Stamina regenerating
	if stamina_cooldown <= 0.:
		regenerate_stamina()

	## Jumping
	# Checking if player is on floor
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		# Checking if player has enough stamina to jump.
		if stamina - jump_stamina_consumption >= 0:
			velocity.y = JUMP_VELOCITY
			use_stamina(jump_stamina_consumption)
	
	## Handle sprint and moving backwards speed.
	# Setting speed for backwards movement.
	if Input.is_action_pressed("move_backward"):
		SPEED = BACKWARDS_SPEED
	# Sprinting conditions
	elif Input.is_action_pressed("move_sprint"):
		# Checking if is player moving while holding sprint.
		if Input.is_action_pressed("move_forward") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
			# Checking if player has enough stamina to sprint.
			if stamina - sprinting_stamina_consumption >= 0:
				SPEED = SPRINT_SPEED
				headbobbing(delta, "sprinting")
				use_stamina(sprinting_stamina_consumption)
			# Set when there is not enough stamina.
			else:
				SPEED = WALKING_SPEED
	# Checking if player is moving backwards while sprinting, then setting correct speed.
	elif Input.is_action_just_pressed("move_sprint") and Input.is_action_pressed("move_backward"):
		SPEED = BACKWARDS_SPEED
	# Basic speed
	else:
		SPEED = WALKING_SPEED

	# Get the input direction and handle the movement/deceleration. Moving only when on floor, not in air.
	if is_on_floor():
		var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerp_speed)
		if direction.length() > 0.03:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
			headbobbing(delta, "walking")
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
			headbobbing(delta, "none")

	move_and_slide()
	print(direction)
