
# /raidtown Usage
# /raidtown points add <username> <#> - Add raid points to a user.
# /raidtown points remove <username> <#> - Removes raid points from a user.
# /raidtown points info <username> - Show the current raid points of a user.
# /raidtown points permission <username> - Add or Remove the permission to start a raid of a user.
# /raidtown raid start <#> - Start the raid using X raid points. [Min 1] [Every raid point is 10 minutes of raid]
# /raidtown raid stop - Stops the current raid.
# Server flags created here
# - raid_active
# - raid_affected_locations
# - raid_affected_blocks
# - raidtime
# - raid_queue
# LuckPerm permission nodes used
# - raid.start

Command_Raid_Town:
    type: command
    debug: false
    name: raidtown
    description: Minecraft Player Raid.
    usage: /raidtown
    script:
        - if !<player.is_op||<context.server>> && !<player.has_permission[raid.start]>:
                - narrate "<red>You do not have permission for that command."
                - stop
        - if <context.args.size> < 2:
            - narrate "<yellow>#<red> ERROR: Not enough arguments."
            - narrate "<yellow>-<red> To add raid points to a user: /raidtown points add <yellow>username <yellow>number"
            - narrate "<yellow>-<red> To remove raid points to a user: /raidtown points remove <yellow>username <yellow>number"
            - narrate "<yellow>-<red> To check the raid points of a user: /raidtown points info <yellow>username"
            - narrate "<yellow>-<red> To add or remove the permission to start a raid of a user: /raidtown points permission <yellow>username"
            - narrate "<yellow>-<red> To start a raid: /raidtown raid start <yellow>number"
            - narrate "<yellow>-<red> To stop the current raid: /raidtown raid stop"
            - stop
        - define target <context.args.get[1]>
        - define action <context.args.get[2]>
        - if <[target]> == points:
            - if <[action]> == add || <[action]> == remove || <[action]> == info || <[action]> == permission:
                - if !<player.is_op||<context.server>>:
                    - narrate "<red> ERROR: Only operators can do that!"
                    - stop
                - define username <server.match_player[<context.args.get[3]>]||null>
                - if <[username]> == null:
                    - narrate "<red> ERROR: Invalid player username OR the player is offline."
                    - stop
                - if <[username].is_op||<context.server>>:
                    - narrate "<red> ERROR: This user is an operator. This command only work for non-operators"
                    - stop
                - if <[action]> == permission:
                    - if !<[username].has_permission[raid.start]>:
                        - execute as_server "lp user <[username].name> permission set raid.start" silent
                        - flag <[username]> raid_points:1
                        - narrate "<green> Added the permission <yellow>raid.start <green>to <blue><[username].name><green>. The user have <yellow>1 <green>raid point by default."
                        - narrate "<blue> <player.name> <green>added the <yellow>raid.start <green>permission to you!" targets:<[username]>
                        - stop
                    - execute as_server "lp user <[username].name> permission unset raid.start" silent
                    - flag <[username]> raid_points:!
                    - narrate "<green> Removed the permission <red>raid.start <green>to <blue><[username].name>"
                    - narrate "<blue> <player.name> <green>removed the <red>raid.start <green>permission to you!" targets:<[username]>
                    - stop
                - if !<[username].has_permission[raid.start]>:
                    - narrate "<red> ERROR: This player doesn't have the permission raid.start"
                    - stop
                - if <[action]> == info:
                    - if !<[username].has_flag[raid_points]>:
                        - narrate "<red> ERROR: The user doesn't have any points assigned to him"
                        - stop
                    - narrate "<green> The user <blue><[username].name> <green>have <yellow><[username].flag[raid_points]> <green>raid points!"
                    - stop
                - if <context.args.size> < 4:
                    - narrate "<yellow>#<red> ERROR: Not enough arguments."
                    - narrate "<yellow>-<red> To add raid points to a user: /raidtown points add <yellow>username <yellow>number"
                    - narrate "<yellow>-<red> To remove raid points to a user: /raidtown points remove <yellow>username <yellow>number"
                    - narrate "<yellow>-<red> To check the raid points of a user: /raidtown points info <yellow>username"
                    - stop
                - define points <context.args.get[4]>
                - if !<[points].is_integer>:
                    - narrate "<red> ERROR: The raid points should be a integer number!"
                    - stop
                - if <[action]> == add:
                    - if <[username].has_flag[raid_points]>:
                        - if <[username].flag[raid_points].add[<[points]>]> < 0:
                            - narrate "<red> ERROR: The user can't have negative raid points!"
                            - stop
                    - flag <[username]> raid_points:+:<[points]>
                    - narrate "<green> Added <yellow><[points]> <green>raid points to <blue><[username].name>"
                    - narrate "<blue> <player.name> <green>added <yellow><[points]> <green>raid points to you!" targets:<[username]>
                    - narrate "<green> Raid points balance: <yellow><[username].flag[raid_points]>" targets:<[username]>
                    - stop
                - if <[action]> == remove:
                    - if !<[username].has_flag[raid_points]>:
                        - narrate "<red> ERROR: Add points first to the user before removing points!"
                        - stop
                    - if <[username].flag[raid_points].sub[<[points]>]> < 0:
                        - narrate "<red> ERROR: The user can't have negative raid points!"
                        - stop
                    - flag <[username]> raid_points:-:<[points]>
                    - narrate "<green> Removed <yellow><[points]> <green>raid points to <blue><[username].name>"
                    - narrate "<blue> <player.name> <green>removed <red><[points]> <green>raid points to you!" targets:<[username]>
                    - narrate "<green> Raid points balance: <yellow><[username].flag[raid_points]>" targets:<[username]>
                    - stop
        - if <[target]> == raid:
            - if <[action]> == start:
                - if <server.has_flag[raid_active]>:
                    - narrate "<red> ERROR: A raid is active, wait for it to finish before starting another one!"
                    - stop
                - if !<player.has_flag[raid_points]> && !<player.is_op||<context.server>>:
                    - narrate "<red> ERROR: You don't have raid points assigned to you!"
                    - stop
                - if <context.args.size> < 3:
                    - narrate "<yellow>#<red> ERROR: Not enough arguments."
                    - narrate "<yellow>-<red> To start a raid: /raidtown raid start <yellow>number"
                    - stop
                - define points <context.args.get[3]>
                - if !<[points].is_integer>:
                    - narrate "<red> ERROR: The raid points should be a integer number!"
                    - stop
                - if !<player.is_op||<context.server>>:
                    - if <player.flag[raid_points].sub[<[points]>]> < 0:
                        - narrate "<red> ERROR: You don't have enough raid points!"
                        - stop
                    - flag <player> raid_points:-:<[points]>
                - define raidtime <[points].mul[600]>
                - flag server raidtime:<[raidtime]>
                - flag server raid_queue:<queue>
                - define max_bar_value 1
                - log "Raid started by <player.name> using <[points]> raid points" file:logs/denizen/raids.txt
                - narrate "<green> Raid has started! The raid will last for <[raidtime].div[60]> minutes!" targets:<server.online_players>
                - narrate "<yellow> WARNING A: <red>Every block change (place or break a block) will be reset at the end of the raid!" targets:<server.online_players>
                - narrate "<yellow> WARNING B: <red>If you place a block, you will lose it. Use them to attack or defend!" targets:<server.online_players>
                - bossbar raidbar players:<server.online_players> color:red "title:RAID - Time remaining" progress:<[max_bar_value]>
                - flag server raid_active:true
                - repeat <[raidtime]>:
                    - define time_remaining:<[raidtime].sub[<[value]>]>
                    - flag server raidtime:<[time_remaining]>
                    - bossbar update raidbar progress:<[time_remaining].div[<[raidtime]>]>
                    - wait 1s
                - bossbar remove raidbar
                - if <server.has_flag[raid_affected_locations]> && <server.has_flag[raid_affected_materials]>:
                    - foreach <server.flag[raid_affected_locations]> as:raid_location:
                        - define raid_block <server.flag[raid_affected_materials].get[<[loop_index]>]>
                        - modifyblock <[raid_location]> <[raid_block]>
                    - flag server raid_affected_locations:!
                    - flag server raid_affected_materials:!
                - flag server raidtime:!
                - flag server raid_queue:!
                - flag server raid_active:!
                - narrate "<green> Raid has ended!" targets:<server.online_players>
                - stop
            - if <[action]> == stop:
                - if !<player.is_op||<context.server>>:
                    - narrate "<red> ERROR: Only operators can do that!"
                    - stop
                - if !<server.has_flag[raid_active]>:
                    - narrate "<red> ERROR: A raid must be active to be stopped!"
                    - stop
                - bossbar raidbar remove
                - if <server.has_flag[raid_affected_locations]> && <server.has_flag[raid_affected_materials]>:
                    - foreach <server.flag[raid_affected_locations]> as:raid_location:
                        - define raid_block <server.flag[raid_affected_materials].get[<[loop_index]>]>
                        - modifyblock <[raid_location]> <[raid_block]>
                    - flag server raid_affected_locations:!
                    - flag server raid_affected_materials:!
                - queue <server.flag[raid_queue]> stop
                - flag server raid_queue:!
                - flag server raidtime:!
                - flag server raid_active:!
                - stop
        - narrate "<yellow>#<red> ERROR: Syntax error. Follow the command syntax:"
        - narrate "<yellow>-<red> To add raid points to a user: /raidtown points add <yellow>username <yellow>number"
        - narrate "<yellow>-<red> To remove raid points from a user: /raidtown points remove <yellow>username <yellow>number"
        - narrate "<yellow>-<red> To check the raid points of a user: /raidtown points info <yellow>username"
        - narrate "<yellow>-<red> To add or remove the permission to start a raid of a user: /raidtown points permission <yellow>username"
        - narrate "<yellow>-<red> To start a raid: /raidtown raid start <yellow>number"
        - narrate "<yellow>-<red> To stop the current raid: /raidtown raid stop"

Raid_Town_Script:
    type: world
    debug: false
    events:
        on player breaks block bukkit_priority:HIGHEST ignorecancelled:true:
            - if <server.has_flag[raid_active]>:
                - if !<context.location.regions.is_empty>:
                    - stop
                - modifyblock <context.location> air
                - if !<server.has_flag[raid_affected_locations]>:
                    - flag server raid_affected_locations:|:<context.location>
                    - flag server raid_affected_materials:|:<context.material>
                    - stop
                - if !<server.flag[raid_affected_locations].contains[<context.location>]>:
                    - flag server raid_affected_locations:|:<context.location>
                    - flag server raid_affected_materials:|:<context.material>
                    - stop
        after player places block bukkit_priority:HIGHEST ignorecancelled:true:
            - if <server.has_flag[raid_active]>:
                - if !<context.location.regions.is_empty>:
                    - stop
                - if !<player.inventory.slot[<player.held_item_slot>].repairable>:
                    - inventory adjust slot:<player.held_item_slot> quantity:<player.inventory.slot[<player.held_item_slot>].quantity.sub[1]>
                    - modifyblock <context.location> <context.material>
                - if !<server.has_flag[raid_affected_locations]>:
                    - flag server raid_affected_locations:|:<context.location>
                    - flag server raid_affected_materials:|:<context.old_material>
                    - stop
                - if !<server.flag[raid_affected_locations].contains[<context.location>]>:
                    - flag server raid_affected_locations:|:<context.location>
                    - flag server raid_affected_materials:|:<context.old_material>
                    - stop
        on player right clicks CHEST bukkit_priority:HIGHEST ignorecancelled:true:
            - if <server.has_flag[raid_active]>:
                - if !<context.location.regions.is_empty>:
                    - stop
                - inventory open d:<context.location>