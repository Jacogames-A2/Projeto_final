extends Node2D

## Scene to instantiate for each player. Assign in the Inspector.
@export var player_scene: PackedScene

@onready var _spawn1: Marker2D = $SpawnPoint1
@onready var _spawn2: Marker2D = $SpawnPoint2
@onready var _hp_bar1: ProgressBar = $UI/HealthBar1
@onready var _hp_bar2: ProgressBar = $UI/HealthBar2
@onready var _score_label: Label = $UI/ScoreLabel
@onready var _round_label: Label = $UI/RoundLabel

var _player1: CharacterBody2D
var _player2: CharacterBody2D
var _round_in_progress: bool = false


func _ready() -> void:
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.game_over.connect(_on_game_over)
	_spawn_players()
	_update_score_label()


func _spawn_players() -> void:
	if player_scene == null:
		push_error("Arena: player_scene is not assigned!")
		return

	_player1 = player_scene.instantiate()
	_player1.player_index = 1
	_player1.global_position = _spawn1.global_position
	add_child(_player1)
	_player1.health_changed.connect(func(hp, max_hp): _on_health_changed(1, hp, max_hp))
	_player1.player_died.connect(_on_player_died)

	_player2 = player_scene.instantiate()
	_player2.player_index = 2
	_player2.global_position = _spawn2.global_position
	add_child(_player2)
	_player2.health_changed.connect(func(hp, max_hp): _on_health_changed(2, hp, max_hp))
	_player2.player_died.connect(_on_player_died)

	_round_in_progress = true


func _on_health_changed(player_index: int, hp: int, max_hp: int) -> void:
	var bar: ProgressBar = _hp_bar1 if player_index == 1 else _hp_bar2
	if bar:
		bar.value = float(hp) / float(max_hp) * 100.0


func _on_player_died(dead_player_index: int) -> void:
	if not _round_in_progress:
		return
	_round_in_progress = false

	var winner_index: int = 2 if dead_player_index == 1 else 1
	GameManager.add_score(winner_index)

	# Only reset if the game hasn't ended (game_over signal handles that)
	if GameManager.get_score(winner_index) < GameManager.max_score:
		await get_tree().create_timer(2.0).timeout
		_reset_round()


func _reset_round() -> void:
	if is_instance_valid(_player1):
		_player1.respawn(_spawn1.global_position)
	if is_instance_valid(_player2):
		_player2.respawn(_spawn2.global_position)

	if _hp_bar1:
		_hp_bar1.value = 100.0
	if _hp_bar2:
		_hp_bar2.value = 100.0

	_update_score_label()
	_round_in_progress = true


func _on_score_changed(_player_index: int, _score: int) -> void:
	_update_score_label()


func _update_score_label() -> void:
	if _score_label:
		_score_label.text = "P1: %d  |  P2: %d" % [
			GameManager.get_score(1),
			GameManager.get_score(2)
		]


func _on_game_over(winner_index: int) -> void:
	if _round_label:
		_round_label.text = "Jogador %d Venceu!" % winner_index
		_round_label.visible = true

	# Freeze both players
	for p in [_player1, _player2]:
		if is_instance_valid(p):
			p.set_physics_process(false)

	await get_tree().create_timer(4.0).timeout
	GameManager.reset_scores()
	get_tree().reload_current_scene()
