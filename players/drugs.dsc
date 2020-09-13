# +----------------------
# |
# | D R U G S
# |
# +----------------------
#
# @author devnodachi
# @date 2020/09/13
# @denizen-build REL-1714
#
# Commands.
# /drugs give <username> medicine <quantity> - Give X drug medicines to the user [quantity: 1~64]
# /drugs give <username> <drugname> <quantity> - Give X drugs to the user [quantity: 1~64]
# /drugs remove <username> - Remove the high effects of the drugs to the user. (It will have withdrawal symptoms)
# Player flags created here
# - drug_used [brown_brown]
# - heroine_amount [1 ~ 10]
# - heroine_tolerance [1 ~ 3]

Command_Drug:
    type: command
    debug: false
    name: drugs
    description: Minecraft Player Drugs.
    usage: /drugs
    tab complete:
        - if !<player.is_op||<context.server>>:
            - stop
        - choose <context.args.size>:
            - case 0:
                - determine <list[give|remove]>
            - case 1:
                - if "!<context.raw_args.ends_with[ ]>":
                    - determine <list[give|remove].filter[starts_with[<context.args.first>]]>
                - else:
                    - determine <server.online_players.parse[name]>
            - case 2:
                - if "!<context.raw_args.ends_with[ ]>":
                    - determine <server.online_players.parse[name]>
                - else:
                    - if <context.args.get[1]> == give:
                        - determine <list[brownbrown|medicine]>
            - case 3:
                - if "!<context.raw_args.ends_with[ ]>":
                    - if <context.args.get[1]> == give:
                        - determine <list[brownbrown|medicine]>
    script:
        - if !<player.is_op||<context.server>>:
                - narrate "<red>You do not have permission for that command."
                - stop
        - if <context.args.size> < 2:
            - goto syntax_error
        - define action <context.args.get[1]>
        - define username <server.match_player[<context.args.get[2]>]||null>
        - if <[username]> == null:
            - narrate "<red> ERROR: Invalid player username OR the player is offline."
            - stop
        - if <[action]> == give:
            - if <context.args.size> < 4:
                - goto syntax_error
            - define target <context.args.get[3]>
            - define amount <context.args.get[4]>
            - if <[amount]> > 0 && <[amount]> <= 64:
                - choose <[target]>:
                    - case brownbrown:
                        - give drug_brown_brown to:<[username].inventory> quantity:<[amount]>
                    - case medicine:
                        - give medicine_drug to:<[username].inventory> quantity:<[amount]>
                    - default:
                        - narrate "<red> ERROR: That drug or medicine doesn't exist"
                        - stop
                - narrate "<green> <[target].to_titlecase> obtained: <blue><[username].name> <green>- Quantity: <yellow><[amount]>"
                - stop
        - if <[action]> == remove:
            - if !<[username].has_flag[drug_duration]>:
                - narrate "<red> ERROR: The user isn't under the effect of drugs"
            - if <[username].has_flag[drug_used_queue]>:
                - queue stop <[username].flag[drug_used_queue]>
            - flag <[username]> drug_duration:!
            - flag <[username]> drug_used_queue:!
            - adjust <[username]> remove_effects
            - narrate "<green> Drug effects removed: <blue><[username].name>"
            - narrate "<white> You may want to give a <yellow>medicine <white>to <blue><[username].name>"
            - stop
        - mark syntax_error
        - narrate "<yellow>#<red> ERROR: Syntax error. Follow the command syntax:"
        - narrate "<yellow>-<red> To give a drug medicine: <white>/drugs give username medicine"
        - narrate "<yellow>-<red> To give a drug: <white>/drugs give <yellow>username name quantity"
        - narrate "<yellow>-<red> To remove the high effects of the drugs (It will have withdrawal symptoms): <white>/drugs remove <yellow>username"

Drugs_Script:
    type: world
    debug: false
    events:
        after player joins:
            - if <player.has_flag[drug_duration]>:
                - if <player.is_online> && <player.flag[drug_used].contains[brown_brown]>:
                    - run Drug_Particle_Task def:brown_brown|<player>|<player.flag[drug_duration]>|3
        on system time secondly:
            - foreach <server.online_players> as:server_player:
                - if <[server_player].has_flag[drug_duration]>:
                    - flag <[server_player]> drug_duration:-:1
                    - if <[server_player].flag[drug_duration]> <= 0:
                        - flag <[server_player]> drug_duration:!
                        - flag <[server_player]> drug_used_queue:!
                - if <[server_player].has_flag[withdrawal_duration]>:
                    - flag <[server_player]> withdrawal_duration:-:1
                    - if <[server_player].flag[withdrawal_duration]> <= 0:
                        - flag <[server_player]> withdrawal_duration:!
                        - flag <[server_player]> drug_used:!
                        - stop
                - if <[server_player].has_flag[drug_used]> && !<[server_player].has_flag[drug_duration]>:
                    - if !<[server_player].has_flag[withdrawal_duration]>:
                        - flag <[server_player]> withdrawal_duration:<script[Drugs_Config].data_key[withdrawal_duration]>
                    - ratelimit <[server_player]> <script[Drugs_Config].data_key[withdrawal_cooldown]>s
                    - cast SLOW duration:<[server_player].flag[withdrawal_duration]>s amplifier:0 <[server_player]> hide_particles
                    - cast BLINDNESS duration:<[server_player].flag[withdrawal_duration]>s amplifier:0 <[server_player]> hide_particles
                    - ratelimit <[server_player]> <script[Drugs_Config].data_key[withdrawal_message_cooldown]>s
                    - actionbar "<yellow> I need more <red>Heroine <yellow>or <red>BrownBrown <yellow>to feel better" target:<[server_player]>
        on player consumes milk_bucket:
            - determine cancelled
        on player right clicks block with:drug_brown_brown:
            - if <player.has_flag[drug_duration]>:
                - narrate "<red> Wait! You can use a drug again in <yellow><player.flag[drug_duration]> seconds"
                - stop
            - take <context.item> from:<player.inventory>
            - if <context.item.script.name> == drug_brown_brown:
                - if <player.has_flag[withdrawal_duration]>:
                    - cast remove BLINDNESS <player>
                    - cast remove SLOW <player>
                - flag <player> drug_duration:<script[Drugs_Config].data_key[drug_duration]>
                - cast INCREASE_DAMAGE duration:<player.flag[drug_duration]>s amplifier:2 <player>
                - cast SLOW_FALLING duration:<player.flag[drug_duration]>s amplifier:0 <player>
                - cast NIGHT_VISION duration:<player.flag[drug_duration]>s amplifier:0 <player>
                - cast REGENERATION duration:<player.flag[drug_duration]>s amplifier:1 <player>
                - feed <player> amount:8 saturation:5
                - flag <player> drug_used:brown_brown
                - run Drug_Particle_Task def:brown_brown|<player>|<script[Drugs_Config].data_key[drug_duration]>|3
            - determine cancelled

Drug_Particle_Task:
    type: task
    debug: false
    definitions: drug_name|particle_player|particle_duration|delay
    script:
            - flag <[particle_player]> drug_used_queue:<queue>
            - repeat <[particle_duration].div[<[delay]>].truncate>:
                - if !<[particle_player].is_online>:
                    - stop
                - if <[drug_name]> == brown_brown:
                    - random:
                        - playeffect effect:DRAGON_BREATH at:<[particle_player].location.up[1]> quantity:100 offset:0.5,0.6,0.5 targets:<[particle_player]>
                        - playeffect effect:SMOKE_NORMAL at:<[particle_player].location.up[1]> quantity:100 offset:0.5,0.6,0.5 targets:<[particle_player]>
                        - playeffect effect:VILLAGER_HAPPY at:<[particle_player].location.up[1]> quantity:100 offset:0.5,0.6,0.5 targets:<[particle_player]>
                - wait <[delay]>s

drug_brown_brown:
    type: item
    debug: false
    material: brown_dye
    mechanisms:
        hides: enchants
    enchantments:
        - unbreaking:1
    display name: <red>Brown Brown
    lore:
        - <green>Time to travel
        - <gray>Right click to use
    recipes:
        1:
            type: shaped
            input:
                - poppy|coal|poppy
                - brown_dye|brown_dye|brown_dye
                - emerald|emerald|emerald