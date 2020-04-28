extends Node

signal action_selected(action)
signal combatant_selected(combatant)
signal combat_animation_ended()
signal damage_targets()

signal ai_chooses_action_and_combatant(attacker, action, targets)

signal combatant_died(combatant)

signal create_popup_at(type, text, start_pos)

signal battle_ended(win_result)
