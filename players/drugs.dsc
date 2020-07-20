## Drugs
# /drugs
# /drugs give <username> medicine <quantity> - Give X drug medicines to the user [quantity: 1~64]
# /drugs give <username> <drugname> <quantity> - Give X drugs to the user [quantity: 1~64]
# /drugs remove <username> - Remove the high effects of the drugs to the user. (It will have withdrawal symptoms)
# Player flags created here
# - drug_duration [60s ~ 600s]
# - drug_used [heroine] [weed] [brown_brown] [drug_mushroom]
# - heroine_amount [1 ~ 10]
# - heroine_tolerance [1 ~ 3]
# - heroine_tolerance_cooldown [14440s]
# - withdrawal_cooldown [60s]
# - withdrawal_duration [7200s]
# - withdrawal_message_cooldown [300s]

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
                        - determine <list[brownbrown|heroine|mushroom|weed|medicine]>
            - case 3:
                - if "!<context.raw_args.ends_with[ ]>":
                    - if <context.args.get[1]> == give:
                        - determine <list[brownbrown|heroine|mushroom|weed|medicine]>
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
                    - case heroine:
                        - give drug_heroine to:<[username].inventory> quantity:<[amount]>
                    - case brownbrown:
                        - give drug_brown_brown to:<[username].inventory> quantity:<[amount]>
                    - case weed:
                        - give drug_weed to:<[username].inventory> quantity:<[amount]>
                    - case mushroom:
                        - give drug_mushroom to:<[username].inventory> quantity:<[amount]>
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
                - if <player.has_flag[drug_used]>:
                    - wait 5s
                - if <player.is_online>:
                    - if <player.flag[drug_used].contains[brown_brown]>:
                        - run Drug_Particle_Task def:brown_brown|<player>|<player.flag[drug_duration]>|3
                    - if <player.flag[drug_used].contains[drug_mushroom]>:
                        - run Drug_Particle_Task def:drug_mushroom|<player>|<player.flag[drug_duration]>|1
        on system time secondly:
            - foreach <server.online_players> as:server_player:
                - if <[server_player].has_flag[heroine_tolerance_cooldown]>:
                    - flag <[server_player]> heroine_tolerance_cooldown:-:1
                    - if <[server_player].flag[heroine_tolerance_cooldown]> <= 0:
                        - flag <[server_player]> heroine_tolerance_cooldown:!
                        - if <[server_player].has_flag[heroine_tolerance]>:
                            - flag <[server_player]> heroine_tolerance:-:1
                            - if <[server_player].flag[heroine_tolerance]> <= 0:
                                - flag <[server_player]> heroine_tolerance:!
                - if <[server_player].has_flag[drug_duration]>:
                    - flag <[server_player]> drug_duration:-:1
                    - if <[server_player].flag[drug_duration]> <= 0:
                        - flag <[server_player]> drug_duration:!
                        - flag <[server_player]> drug_used_queue:!
                - if <[server_player].has_flag[drug_used]> && !<[server_player].has_flag[drug_duration]>:
                    - if !<[server_player].has_flag[withdrawal_duration]>:
                        - flag <[server_player]> withdrawal_duration:7200
                    - flag <[server_player]> withdrawal_duration:-:1
                    - if <[server_player].flag[withdrawal_duration]> <= 0:
                        - flag <[server_player]> withdrawal_duration:!
                        - flag <[server_player]> drug_used:!
                        - flag <[server_player]> withdrawal_cooldown:!
                        - flag <[server_player]> withdrawal_message_cooldown:!
                        - stop
                    - if <[server_player].has_flag[withdrawal_cooldown]>:
                        - flag <[server_player]> withdrawal_cooldown:-:1
                        - if <[server_player].flag[withdrawal_cooldown]> <= 0:
                            - flag <[server_player]> withdrawal_cooldown:!
                    - if <[server_player].has_flag[withdrawal_message_cooldown]>:
                        - flag <[server_player]> withdrawal_message_cooldown:-:1
                        - if <[server_player].flag[withdrawal_message_cooldown]> <= 0:
                            - flag <[server_player]> withdrawal_message_cooldown:!
                    - if !<[server_player].has_flag[withdrawal_cooldown]>:
                        - cast SLOW duration:<[server_player].flag[withdrawal_duration]>s amplifier:0 <[server_player]> hide_particles
                        - cast BLINDNESS duration:<[server_player].flag[withdrawal_duration]>s amplifier:0 <[server_player]> hide_particles
                        - if !<[server_player].has_flag[withdrawal_message_cooldown]>:
                            - actionbar "<yellow> I need more <red>Heroine <yellow>or <red>BrownBrown <yellow>to feel better" target:<[server_player]>
                            - flag <[server_player]> withdrawal_message_cooldown:300
                        - flag <[server_player]> withdrawal_cooldown:60
        on player consumes milk_bucket:
            - determine cancelled
        on player right clicks block with:drug_heroine|drug_brown_brown|drug_weed|drug_mushroom:
            - if <player.has_flag[drug_duration]>:
                - narrate "<red> Wait! You can use a drug again in <yellow><player.flag[drug_duration]> seconds"
                - stop
            - take <context.item> from:<player.inventory>
            - choose <context.item.script.name>:
                - case drug_heroine:
                    - if <player.has_flag[withdrawal_duration]>:
                        - cast remove BLINDNESS <player>
                        - cast remove SLOW <player>
                    - if <player.has_flag[heroine_amount]> && <player.flag[heroine_amount]> == 10:
                        - flag <player> heroine_amount:0
                        - if !<player.has_flag[heroine_tolerance]>:
                            - flag <player> heroine_tolerance:0
                        - if <player.flag[heroine_tolerance]> < 3:
                            - flag <player> heroine_tolerance:+:1
                            - flag <player> heroine_tolerance_cooldown:14440
                            - narrate "<yellow> Tolerance level changed. The drug will last less time"
                            - narrate "<yellow> Wait 1 day to lower the tolerance by one level"
                    - flag <player> drug_duration:600
                    - if <player.has_flag[heroine_tolerance]>:
                        - if <player.flag[heroine_tolerance]> == 1:
                            - flag <player> drug_duration:480
                        - if <player.flag[heroine_tolerance]> == 2:
                            - flag <player> drug_duration:300
                        - if <player.flag[heroine_tolerance]> == 3:
                            - flag <player> drug_duration:60
                    - cast INCREASE_DAMAGE duration:<player.flag[drug_duration]>s amplifier:2 <player> hide_particles
                    - cast NIGHT_VISION duration:<player.flag[drug_duration]>s amplifier:0 <player> hide_particles
                    - cast SLOW duration:<player.flag[drug_duration]>s amplifier:2 <player> hide_particles
                    - feed <player> amount:8 saturation:5
                    - flag <player> heroine_amount:+:1
                    - flag <player> drug_used:heroine
                    - define random_chance <util.random.int[1].to[10]>
                    - if <[random_chance]> == 1:
                        - playeffect SPIT at:<player.location> quantity:10
                        - wait 3s
                        - narrate "<red> You couldn't handle the Heroine"
                        - if !<player.has_flag[heroine_tolerance]>:
                            - flag <player> heroine_tolerance:0
                        - if <player.flag[heroine_tolerance]> < 3:
                            - flag <player> heroine_tolerance:+:1
                            - flag <player> heroine_tolerance_cooldown:14400
                            - narrate "<yellow> Tolerance level changed. The drug will last less time"
                            - narrate "<yellow> Wait 1 day to lower the tolerance by one level"
                        - hurt 999 <player>
                - case drug_brown_brown:
                    - if <player.has_flag[withdrawal_duration]>:
                        - cast remove BLINDNESS <player>
                        - cast remove CONFUSION <player>
                        - cast remove SLOW <player>
                    - flag <player> drug_duration:600
                    - cast INCREASE_DAMAGE duration:<player.flag[drug_duration]>s amplifier:2 <player>
                    - cast SLOW_FALLING duration:<player.flag[drug_duration]>s amplifier:0 <player>
                    - cast NIGHT_VISION duration:<player.flag[drug_duration]>s amplifier:0 <player>
                    - cast REGENERATION duration:<player.flag[drug_duration]>s amplifier:1 <player>
                    - feed <player> amount:8 saturation:5
                    - flag <player> drug_used:brown_brown
                    - run Drug_Particle_Task def:brown_brown|<player>|600|3
                - case drug_weed:
                    - flag <player> drug_duration:600
                    - cast NIGHT_VISION duration:<player.flag[drug_duration]>s amplifier:0 <player> hide_particles
                    - cast REGENERATION duration:<player.flag[drug_duration]>s amplifier:0 <player> hide_particles
                    - cast LUCK duration:<player.flag[drug_duration]>s amplifier:0 <player> hide_particles
                    - flag <player> drug_used:weed
                - case drug_mushroom:
                    - flag <player> drug_duration:600
                    - cast LUCK duration:<player.flag[drug_duration]>s amplifier:0 <player> hide_particles
                    - run Drug_Particle_Task def:drug_mushroom|<player>|600|1
                    - flag <player> drug_used:drug_mushroom
                - default:
                    - determine cancelled
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
                - if <[drug_name]> == drug_mushroom:
                    - showfake NETHER_PORTAL <[particle_player].location> players:<[particle_player]> d:<[delay]>s
                - if <[drug_name]> == brown_brown:
                    - random:
                        - playeffect effect:DRAGON_BREATH at:<[particle_player].location.up[1]> quantity:100 offset:0.5,0.6,0.5 targets:<[particle_player]>
                        - playeffect effect:SMOKE_NORMAL at:<[particle_player].location.up[1]> quantity:100 offset:0.5,0.6,0.5 targets:<[particle_player]>
                        - playeffect effect:VILLAGER_HAPPY at:<[particle_player].location.up[1]> quantity:100 offset:0.5,0.6,0.5 targets:<[particle_player]>
                - wait <[delay]>s

drug_heroine:
    type: item
    debug: false
    material: black_dye
    mechanisms:
        hides: enchants
    enchantments:
        - unbreaking:1
    display name: <red>Heroine
    lore:
        - <green>You will feel powerful!
        - <gray>Right click to use
        - <gray>The more you use it, the worse it gets
        - <red>Do not mix it!
    recipes:
        1:
            type: shaped
            input:
                - air|tripwire_hook|air
                - emerald|coal|emerald
                - poppy|emerald|poppy

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

drug_weed:
    type: item
    debug: false
    material: green_dye
    mechanisms:
        hides: enchants
    enchantments:
        - unbreaking:1
    display name: <green>Weed
    lore:
        - <yellow>Fortune awaits!
        - <gray>Right click to use
    recipes:
        1:
            type: shaped
            input:
                - grass|grass|grass
                - air|emerald|air

drug_mushroom:
    type: item
    debug: false
    material: brown_mushroom
    mechanisms:
        hides: enchants
    enchantments:
        - unbreaking:1
    display name: <red>Mushroom
    lore:
        - <red>Dizzy times
        - <gray>Right click to use
    recipes:
        1:
            type: shaped
            input:
                - emerald|red_mushroom|emerald