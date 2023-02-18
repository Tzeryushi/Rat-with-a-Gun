extends Actor

export var _gravity : float = 50
export var _terminal_velo : float = 800
export var _bob_impulse : float = 2

var velocity : Vector2 = Vector2.ZERO

onready var starting_position : Vector2 = position

func _physics_process(_delta):
	if position.y > starting_position.y-5:
		_bob_up()
	velocity.y = move_toward(velocity.y, _terminal_velo, _gravity*_delta)
	velocity = move_and_slide(velocity, Vector2.UP)

func _bob_up() -> void:
	#adds an impulse to the gooby to keep it afloat
	velocity.y -= _bob_impulse

func be_bounced_on() -> void:
	.be_bounced_on()
	queue_free()
