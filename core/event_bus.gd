## EventBus - Global Signal Bus
##
## Provides decoupled communication between modules.
## Core Systems have ZERO dependencies on other modules.
## Other modules emit/listen to EventBus signals.
##
## Usage:
##   # Emit from any module
##   EventBus.player_died.emit(run_stats)
##
##   # Listen from any module
##   EventBus.player_died.connect(_on_player_died)
extends Node

# =============================================================================
# COMBAT SIGNALS
# =============================================================================

## Emitted when the player dies
## @param run_stats: Dictionary with time_survived, enemies_killed, boss_defeated
signal player_died(run_stats: Dictionary)

## Emitted when player takes damage
## @param amount: Damage amount
## @param source: What caused the damage
signal player_damaged(amount: int, source: String)

## Emitted when player health changes
## @param current_hp: Current health points
## @param max_hp: Maximum health points
signal player_health_changed(current_hp: int, max_hp: int)

## Emitted when an enemy is killed
## @param enemy_type: Type of enemy killed
## @param position: World position where enemy died
signal enemy_killed(enemy_type: String, position: Vector2)

## Emitted when a boss is defeated
## @param boss_id: Identifier of the boss
## @param evidence_reward: Evidence unlocked by defeating boss
signal boss_defeated(boss_id: String, evidence_reward: String)

# =============================================================================
# MUTATION SIGNALS
# =============================================================================

## Emitted when player levels up and can choose mutation
## @param options: Array of 3 mutation choices
signal level_up(options: Array)

## Emitted when a mutation is selected
## @param mutation_data: Dictionary with mutation details
signal mutation_selected(mutation_data: Dictionary)

## Emitted when pollution index changes
## @param new_value: Total pollution value
signal pollution_changed(new_value: int)

## Emitted when a synergy is activated
## @param synergy_data: Dictionary with synergy details
signal synergy_activated(synergy_data: Dictionary)

## Emitted when level-up UI is shown
signal level_up_shown()

## Emitted when level-up UI is hidden
signal level_up_hidden()

## Emitted when player is healed
## @param amount: Amount healed
signal player_healed(amount: int)

## Emitted when a special ability is used
## @param ability_data: Dictionary with ability details
signal ability_used(ability_data: Dictionary)

# =============================================================================
# CONSPIRACY BOARD SIGNALS
# =============================================================================

## Emitted when new evidence is unlocked
## @param evidence_id: ID of the evidence/data log
signal evidence_unlocked(evidence_id: String)

## Emitted when evidence is dropped by a boss or enemy
## @param evidence_id: ID of the evidence that was dropped
signal evidence_dropped(evidence_id: String)

## Emitted when a connection is made between two documents
## @param from_id: Source document ID
## @param to_id: Target document ID
signal connection_made(from_id: String, to_id: String)

## Emitted when conspiracy board state changes
## @param total_connections: Total connections made
## @param total_documents: Total documents collected
signal board_updated(total_connections: int, total_documents: int)

# =============================================================================
# META-PROGRESSION SIGNALS
# =============================================================================

## Emitted when an informant is unlocked
## @param informant_id: ID of the informant
signal informant_unlocked(informant_id: String)

## Emitted when a hint is given by an informant
## @param hint_text: The hint message
## @param hints_remaining: Hints left this run
signal hint_given(hint_text: String, hints_remaining: int)

## Emitted when run ends (death or victory)
## @param result: "death" or "victory"
## @param stats: Run statistics dictionary
signal run_ended(result: String, stats: Dictionary)

# =============================================================================
# SAVE SYSTEM SIGNALS
# =============================================================================

## Emitted when save starts
signal save_started()

## Emitted when save completes successfully
signal save_completed()

## Emitted when save fails
## @param error: Error message
signal save_failed(error: String)

## Emitted when load completes
## @param success: Whether load was successful
signal load_completed(success: bool)

# =============================================================================
# GAME STATE SIGNALS
# =============================================================================

## Emitted when game state changes
## @param from_state: Previous state
## @param to_state: New state
signal state_changed(from_state: String, to_state: String)

## Emitted when game is paused/unpaused
## @param is_paused: Current pause state
signal pause_toggled(is_paused: bool)


# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	# EventBus is autoloaded, no setup needed
	pass
