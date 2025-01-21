extends KinematicBody2D

onready var wanderController = $WanderController

var state = IDLE
var velocity = Vector2.ZERO
var acceleration = 50
var max_speed = 50

enum {
	IDLE,
	WANDER
}

func _ready():
	state = pick_random_state([IDLE, WANDER])

func _physics_process(delta):
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, 200 * delta)
			if wanderController.get_time_left() == 0:
				update_wander()
			
		WANDER:
			if wanderController.get_time_left() == 0:
				update_wander()
			acceleration_towards_point(wanderController.target_position, delta)
			
			if global_position.distance_to(wanderController.target_position) <= WANDER:
				update_wander()
	
	velocity = move_and_slide(velocity)
			
func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func update_wander():
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_timer(rand_range(1, 3))
	
func acceleration_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * max_speed, acceleration * delta)
