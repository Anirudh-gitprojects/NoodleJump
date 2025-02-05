extends CharacterBody2D
class_name Player

signal died

@onready var animator = $AnimationPlayer
@onready var cshape = $CollisionShape2D

var speed = 300.0
var accelerometer_speed = 130.0

var gravity = 15.0
var max_fall_velocity = 1000.0
var jump_velocity = -800

var viewport_size

var use_accelerometer = false

var dead = false

func _ready():
	viewport_size = get_viewport_rect().size
	
	var os_name = OS.get_name()
	if os_name == "Android" || os_name == "iOS":
		use_accelerometer = true

func _process(_delta):
	if velocity.y > 0:
		if animator.current_animation != "fall":
			animator.play("fall")
	elif velocity.y < 0:
		if animator.current_animation != "jump":
			animator.play("jump")

func _physics_process(_delta):
	velocity.y += gravity
	if velocity.y > max_fall_velocity:
		velocity.y = max_fall_velocity
	
	if !dead:
		if use_accelerometer:
			var mobile_input = Input.get_accelerometer()
			velocity.x = mobile_input.x * accelerometer_speed
		else:
			var direction = Input.get_axis("move_left", "move_right")
			if direction:
				velocity.x = direction * speed
			else:
				velocity.x = move_toward(velocity.x, 0, speed)
	
	move_and_slide()
	
	var margin = 20
	if global_position.x > viewport_size.x + margin:
		global_position.x = -margin
	if global_position.x < -margin:
		global_position.x = viewport_size.x + margin

func jump():
	velocity.y = jump_velocity
	SoundFX.play("Jump")

func _on_visible_on_screen_notifier_2d_screen_exited():
	die()

func die():
	if !dead:
		dead = true
		cshape.set_deferred("disabled", true)
		died.emit()
		SoundFX.play("Fall")
