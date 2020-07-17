# TODO
# Add the daily timer for the tolerance level

Drugs_Script:
    type: world
    debug: false
    events:
        on system time minutely:
            - foreach <server.online_players> as:server_player:
                - if <[server_player].has_flag[used_drugs]>:
                    - if !<[server_player].has_flag[withdrawal_duration]>:
                        - flag <[server_player]> withdrawal_duration:5
                    - flag <[server_player]> withdrawal_duration:-:1
                    - if <[server_player].flag[withdrawal_duration]> <= 0:
                        - flag <[server_player]> withdrawal_duration:!
                        - flag <[server_player]> used_drugs:!
                        - stop
                    - if <script[Drugs_Script].cooled_down[<[server_player]>]>:
                        - cast SLOW duration:<[server_player].flag[withdrawal_duration]>m amplifier:0 <[server_player]> hide_particles
                        - cast BLINDNESS duration:<[server_player].flag[withdrawal_duration]>m amplifier:0 <[server_player]> hide_particles
                        - cast CONFUSION duration:<[server_player].flag[withdrawal_duration]>m amplifier:0 <[server_player]> hide_particles
                        - narrate "<yellow> I'm feeling bad after using drugs... My mind is telling me to use more <red>Heroine <yellow>or <red>BrownBrown <yellow>to feel better" target:<[server_player]>
        on player consumes milk_bucket:
            - determine cancelled
        on player right clicks block with:drug_heroine|drug_brown_brown|drug_weed|drug_mushroom:
            - if !<script[Drugs_Script].cooled_down[<player>]>:
                - narrate "<red> Wait! You can use a drug again in <yellow><script[Drugs_Script].cooldown[<player>].in_seconds.truncate> seconds"
                - stop
            - take <context.item> from:<player.inventory>
            - choose <context.item.script.name>:
                - case drug_heroine:
                    - if <player.has_flag[withdrawal_duration]>:
                        - cast remove BLINDNESS <player>
                        - cast remove CONFUSION <player>
                        - cast remove SLOW <player>
                    - if <player.has_flag[heroine_amount]> && <player.flag[heroine_amount]> == 10:
                        - flag <player> heroine_amount:0
                        - if !<player.has_flag[heroine_tolerance]>:
                            - flag <player> heroine_tolerance:0
                        - if <player.flag[heroine_tolerance]> < 3:
                            - flag <player> heroine_tolerance:+:1
                            - narrate "<yellow> Tolerance level changed. The drug will last less time"
                            - narrate "<yellow> Wait 1 day to lower the tolerance by one level"
                    - flag <player> heroine_duration:10
                    - if <player.has_flag[heroine_tolerance]>:
                        - if <player.flag[heroine_tolerance]> == 1:
                            - flag <player> heroine_duration:8
                        - if <player.flag[heroine_tolerance]> == 2:
                            - flag <player> heroine_duration:5
                        - if <player.flag[heroine_tolerance]> == 3:
                            - flag <player> heroine_duration:1
                    - define drug_duration <player.flag[heroine_duration]>
                    - flag <player> heroine_duration:!
                    - cast INCREASE_DAMAGE duration:<[drug_duration]>m amplifier:2 <player> hide_particles
                    - cast NIGHT_VISION duration:<[drug_duration]>m amplifier:0 <player> hide_particles
                    - cast SLOW duration:<[drug_duration]>m amplifier:2 <player> hide_particles
                    - feed <player> amount:8 saturation:10
                    - flag <player> heroine_amount:+:1
                    - flag <player> used_drugs:true
                    - define random_chance <util.random.int[1].to[10]>
                    - if <[random_chance]> == 1:
                        - playeffect SPIT at:<player.location> quantity:10
                        - wait 3s
                        - narrate "<red> You couldn't handle the drug. RIP"
                        - if !<player.has_flag[heroine_tolerance]>:
                            - flag <player> heroine_tolerance:0
                        - if <player.flag[heroine_tolerance]> < 3:
                            - flag <player> heroine_tolerance:+:1
                            - narrate "<yellow> Tolerance level changed. The drug will last less time"
                            - narrate "<yellow> Wait 1 day to lower the tolerance by one level"
                        - hurt 999 <player>
                - default:
                    - determine cancelled
            - cooldown 1m script:Drugs_Script
            - determine cancelled

drug_heroine:
    type: item
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
    material: green_dye
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