# /slavelead usage
# /slavelead start <slavename> - Forces the slave to follow you within X blocks.
# /slavelead limit <slavename> <amount> - Sets the slave space between you and him. [Default: 10] [Min: 10] [Max: 30]
# /slavelead control <slavename> - A SupremeWarden takes control or stop control of a slave that has a jail associated.
# /slavelead free <slavename> - A Godvip or a SupremeWarden frees a slave
# /slavelead lead - Gives the player a Slave Lead
# Additional notes
# - If a SupremeWarden controlling a slave leaves the server, the slave will go back to the jail.
# Player flags created here
# - owner_block_limit [Used in SlaveShop]
# - jail_owner
# - spawn_on_jail

Command_Slave_Lead:
    type: command
    debug: false
    name: slavelead
    description: Minecraft slave lead system.
    usage: /slavelead
    tab complete:
        - if !<player.is_op||<context.server>> && !<player.in_group[supremewarden]> && !<player.in_group[godvip]>:
            - stop
        - choose <context.args.size>:
            - case 0:
                - determine <list[lead|start|limit|free]>
            - case 1:
                - if "!<context.raw_args.ends_with[ ]>":
                    - determine <list[lead|start|limit|free].filter[starts_with[<context.args.first>]]>
                - else:
                    - if <context.args.get[1]> != lead:
                        - determine <server.online_players.filter[in_group[slave]].parse[name]>
            - case 2:
                - if "!<context.raw_args.ends_with[ ]>":
                    - if <context.args.get[1]> != lead:
                        - determine <server.online_players.filter[in_group[slave]].parse[name]>
    script:
        - if !<player.is_op||<context.server>> && !<player.in_group[supremewarden]> && !<player.in_group[godvip]>:
            - narrate "<red>You do not have permission for that command."
            - stop
        - define action <context.args.get[1]>
        - if <context.args.get[1]> == lead:
            - give slave_lead to:<player.inventory>
            - stop
        - if <context.args.size> < 2:
            - narrate "<yellow>#<red> ERROR: Not enough arguments. Follow the command syntax:"
            - narrate "<yellow>-<red> To start forcing a slave to follow you: /slavelead <yellow>slavename <red>start"
            - narrate "<yellow>-<red> To stop forcing a slave to follow exit the server and enter again"
            - narrate "<yellow>-<red> [SupremeWarden] To start controlling or stop controlling a jail slave to follow you: /slavelead <yellow>slavename <red>control"
            - stop
        - define slave <server.match_player[<context.args.get[2]>]||null>
        - if <[slave]> == null:
            - narrate "<red> ERROR: Invalid player username OR the player is offline."
            - stop
        - if !<[slave].in_group[slave]>:
            - narrate "<red> ERROR: This user isn't a slave"
            - stop
        - if !<[slave].has_flag[owner]>:
            - narrate "<red> ERROR: This user isn't a valid slave"
            - stop
        - if <[action]> == start:
            - inject Slave_Lead_Task instantly
        - if <[action]> == limit && <context.args.size> == 3:
            - if !<[slave].flag[owner].contains_all_case_sensitive_text[<player.uuid>]>
                - narrate "<red> ERROR: This slave isn't yours"
                - stop
            - define limit_number <context.args.get[3]>
            - if <[limit_number]> < 10 && <[limit_number]> > 30:
                - narrate "<red> ERROR: The space limit between you and your slave only can be set between <yellow>10-30 <red>blocks"
                - stop
            - flag <[slave]> owner_block_limit:<[limit_number]>
            - narrate "<green> The space between your slave and you will be <yellow><[limit_number]> <green>blocks"
            - stop
        - if <[action]> == free:
            - if <[slave].has_flag[jail_owner]>:
                - define jail_slaves <[slave].flag[jail_owner]>_slaves
                - flag server <[jail_slaves]>:<-:<[slave]>
            - flag <[slave]> owner:!
            - flag <[slave]> slave_timer:!
            - flag <[slave]> jail_owner:!
            - flag <[slave]> owner_block_limit:!
            - execute as_server "lp user <[slave].name> parent remove slave" silent
            - narrate "<green> The slave <red><[slave].name> <green>is now free!"
            - stop
        - narrate "<yellow>#<red><red> ERROR: Syntax error. Follow the command syntax:"
        - narrate "<yellow>-<red><red> To start forcing a slave to follow you: /slavelead <yellow>slavename <red>start"
        - narrate "<yellow>-<red><red> To stop forcing a slave to follow you re-enter the server"
        - narrate "<yellow>-<red><red> [SupremeWarden] To start controlling or stop controlling a jail slave to follow you: /slavelead <yellow>slavename <red>control"

slave_lead:
    type: item
    material: lead
    mechanisms:
        hides: enchants
    enchantments:
        - unbreaking:1
        - vanishing_curse
    display name: <red>Slave Lead
    lore:
        - <gray>Use this on a slave to control it
        - <red>Lost on death

Slave_Lead_Script:
    type: world
    debug: false
    events:
        on player right clicks player with:slave_lead:
            - if !<script[Slave_Lead_Script].cooled_down[<player>]>:
                - stop
            - define slave <context.entity>
            - if !<[slave].in_group[slave]>:
                - narrate "<red> ERROR: This user isn't a slave"
                - stop
            - if !<[slave].has_flag[owner]>:
                - narrate "<red> ERROR: This user isn't a valid slave"
                - stop
            - cooldown 5s script:Slave_Lead_Script
            - inject Slave_Lead_Task instantly
        on player quits:
            - if <player.has_flag[owned_slaves]> && <player.has_flag[soldier_jail]>:
                - foreach <player.flag[owned_slaves]> as:owned_slave:
                    - define slave <player[<[owned_slave]>]>
                    - if <[slave].is_online> && <[slave].has_flag[jail_owner]>:
                        - define jail_spawn <[slave].flag[jail_owner]>_spawn
                        - flag <[slave]> owner:<[slave].flag[jail_owner]>
                        - flag <[slave]> owner_block_limit:!
                        - flag <[slave]> slave_timer:120
                        - teleport <[slave]> <location[<[jail_spawn]>]>
                        - narrate "<blue> <player.name> <red>log out. Welcome back to Jail" targets:<[slave]>
                        - flag <[slave]> jail_owner:!
                - flag <player> owned_slaves:!
                - stop
            - if <player.in_group[slave]> && <player.has_flag[jail_owner]>:
                - flag <player> owner:<player.flag[jail_owner]>
                - flag <player> owner_block_limit:!
                - flag <player> slave_timer:120
                - flag <player> jail_owner:!
                - flag <player> spawn_on_jail:true
        after player joins:
            - wait 5s
            - if <player.is_online> && <player.in_group[slave]> && <player.has_flag[spawn_on_jail]>:
                - narrate "<red> You tried to escape from the lead of the <blue>Supreme Warden<red>. Good try"
                - teleport <player> <location[<player.flag[owner]>_spawn]>
                - flag <player> spawn_on_jail:!