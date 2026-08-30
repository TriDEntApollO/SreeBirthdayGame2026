class_name GameInputEvent

static var direction: Vector2
static var press_order: Array[String] = []


static func movement_input() -> Vector2:
	if not GameState.can_move:
		return direction
	# Maintain most-recently-pressed order.
	var actions = ["walk_left", "walk_right", "walk_up", "walk_down"]
	for act in actions:
		if Input.is_action_just_pressed(act):
			press_order.erase(act)
			press_order.push_back(act)

		if Input.is_action_just_released(act):
			press_order.erase(act)

	var left := Input.is_action_pressed("walk_left")
	var right := Input.is_action_pressed("walk_right")
	var up := Input.is_action_pressed("walk_up")
	var down := Input.is_action_pressed("walk_down")

	# Resolve horizontal axis.
	var horizontal := 0
	if left != right:
		horizontal = -1 if left else 1

	# Resolve vertical axis.
	var vertical := 0
	if up != down:
		vertical = -1 if up else 1
	
	#print("Horizontal: ", horizontal, " Vertical: ", vertical)
	
	# Both axes are either neutral or cancelled.
	if horizontal == 0 and vertical == 0:
		direction = Vector2.ZERO
	# Only one axis survives.
	elif horizontal == 0:
		direction = Vector2(0, vertical)
	elif vertical == 0:
		direction = Vector2(horizontal, 0)
		return direction
	# Both axes survive.
	else:
		# Most recently pressed surviving direction gets priority.
		for i in range(press_order.size() - 1, -1, -1):
			match press_order[i]:
				"walk_left":
					if horizontal == -1:
						direction = Vector2.LEFT
						return direction
				"walk_right":
					if horizontal == 1:
						direction = Vector2.RIGHT
						return direction
				"walk_up":
					if vertical == -1:
						direction = Vector2.UP
						return direction
				"walk_down":
					if vertical == 1:
						direction = Vector2.DOWN
						return direction
				_:
					direction = Vector2.ZERO
					return direction

	return direction


static func is_movement_input() -> bool:
	if direction == Vector2.ZERO:
		return false
	return true

static func cancel() -> bool:
	if Input.is_action_just_pressed("ui_cancel"):
		return true
	return false

static func interact() -> bool:
	if Input.is_action_just_pressed("interact"):
		return true
	return false
	
static func action() -> bool:
	if Input.is_action_just_pressed("action"):
		return true
	return false
	
static func grabbed() -> bool:
	if Input.is_action_pressed("left_click") or Input.is_action_pressed("interact"):
		return true
	return false
