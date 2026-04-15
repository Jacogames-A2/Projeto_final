extends CharacterBody2D

## Which player controls this character (1 or 2).
@export var player_index: int = 1

const SPEED = 300.0
const JUMP_VELOCITY = -500.0

@export var max_health: int = 100
var health: int = max_health
var is_dead: bool = false

var _attack_cooldown: float = 0.0
const ATTACK_COOLDOWN_TIME: float = 0.5
const ATTACK_DAMAGE: int = 10
const ATTACK_RANGE: float = 80.0
const KNOCKBACK_FORCE: float = 350.0

var _knockback: Vector2 = Vector2.ZERO

signal health_changed(new_health: int, max_hp: int)
signal player_died(player_index: int)


func _ready() -> void:
	health = max_health
	add_to_group("players")


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Knockback decays over time
	if _knockback.length() > 1.0:
		_knockback = _knockback.move_toward(Vector2.ZERO, 600.0 * delta)
		velocity.x = _knockback.x
	else:
		_knockback = Vector2.ZERO
		var direction := _get_move_axis()
		velocity.x = direction * SPEED if direction else move_toward(velocity.x, 0.0, SPEED)

	# Jump
	if _is_jump_just_pressed() and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Attack
	_attack_cooldown -= delta
	if _is_attack_just_pressed() and _attack_cooldown <= 0.0:
		_perform_attack()

	move_and_slide()


func take_damage(amount: int, knockback_dir: Vector2 = Vector2.ZERO) -> void:
	if is_dead:
		return
	health = max(0, health - amount)
	health_changed.emit(health, max_health)
	if knockback_dir != Vector2.ZERO:
		_knockback = knockback_dir * KNOCKBACK_FORCE
	if health == 0:
		_die()


func respawn(spawn_position: Vector2) -> void:
	is_dead = false
	health = max_health
	global_position = spawn_position
	velocity = Vector2.ZERO
	_knockback = Vector2.ZERO
	modulate = Color.WHITE
	health_changed.emit(health, max_health)


# --- Private helpers ---

func _get_move_axis() -> float:
	if player_index == 1:
		return Input.get_axis("p1_left", "p1_right")
	return Input.get_axis("p2_left", "p2_right")


func _is_jump_just_pressed() -> bool:
	if player_index == 1:
		return Input.is_action_just_pressed("p1_jump")
	return Input.is_action_just_pressed("p2_jump")


func _is_attack_just_pressed() -> bool:
	if player_index == 1:
		return Input.is_action_just_pressed("p1_attack")
	return Input.is_action_just_pressed("p2_attack")


func _perform_attack() -> void:
	_attack_cooldown = ATTACK_COOLDOWN_TIME
	# Determine facing direction: prefer velocity, fall back to player side
	var facing: float = sign(velocity.x) if velocity.x != 0.0 else (1.0 if player_index == 1 else -1.0)
	var hit_origin: Vector2 = global_position + Vector2(facing * ATTACK_RANGE * 0.5, 0.0)

	for target in get_tree().get_nodes_in_group("players"):
		if target == self:
			continue
		if hit_origin.distance_to(target.global_position) <= ATTACK_RANGE:
			var dir: Vector2 = (target.global_position - global_position).normalized()
			target.take_damage(ATTACK_DAMAGE, dir)


func _die() -> void:
	is_dead = true
	modulate = Color(1.0, 0.3, 0.3, 0.5)
	player_died.emit(player_index)
