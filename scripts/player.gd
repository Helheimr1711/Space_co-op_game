extends CharacterBody3D

@onready var camera = $Camera3D

## Movement
# Speed variables
var SPEED := 5.0
const WALKING_SPEED := 8.0
const SPRINT_SPEED := 12.0
const BACKWARDS_SPEED := 5.0
const JUMP_VELOCITY := 4.5

# Direction global variable
var direction := Vector3.ZERO
# Lerp speed for smooth movement
var lerp_speed := 10
# Stamina variables, not final numbers!
var stamina_max := 50
var stamina := 50
var jump_stamina_consumption := 11
var sprinting_stamina_consumption := 2
var stamina_wait_time := 2.
var stamina_cooldown := 0.

var mouse_sens := 0.25


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Looking and setting direction by mouse.
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		camera.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89), deg_to_rad(89))

## Stamina functions
func use_stamina(stamina_decrease) -> void:
	stamina -= stamina_decrease
	stamina_cooldown = stamina_wait_time
func regenerate_stamina() -> void:
	if stamina < stamina_max:
		stamina += 1


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if stamina_cooldown > 0.:
		stamina_cooldown -= delta

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
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	print(stamina)
