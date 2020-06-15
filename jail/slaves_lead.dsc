# /slavelead usage
# /slavelead start <slavename> - Forces the slave to follow you within X blocks.
# /slavelead limit <slavename> <amount> - Sets the slave space between you and him. [Default: 10] [Min: 10] [Max: 30]
# /slavelead control <slavename> - A SupremeWarden takes control or stop control of a slave that has a jail associated.
# /slavelead free <slavename> - A Godvip or a SupremeWarden frees a slave
# Additional notes
# - If a SupremeWarden controlling a slave leaves the server, the slave will go back to the jail.
# Player flags created here
# - owner_block_limit [Used in SlaveShop]
# - jail_owner

Command_Slave_Lead:
    type: command
    debug: false
    name: slavelead
    description: Minecraft slave lead system.
    usage: /slavelead
    script:
        - if !<player.is_op||<context.server>> && !<player.in_group[supremewarden]> && !<player.in_group[godvip]>:
            - narrate "<red>You do not have permission for that command."
            - stop
        - if <context.args.size> < 2:
            - narrate "<yellow>#<red> ERROR: Not enough arguments. Follow the command syntax:"
            - narrate "<yellow>-<red> To start forcing a slave to follow you: /slavelead <yellow>slavename <red>start"
            - narrate "<yellow>-<red> To stop forcing a slave to follow exit the server and enter again"
            - narrate "<yellow>-<red> [SupremeWarden] To start controlling or stop controlling a jail slave to follow you: /slavelead <yellow>slavename <red>control"
            - stop
        - define action <context.args.get[1]>
        - define slave <server.match_player[<context.args.get[2]>]||null>
        - if <[slave]> == null:
            - narrate "<red> ERROR: Wrong username. Try again."
            - stop
        - if !<[slave].in_group[slave]>:
            - narrate "<red> ERROR: This user isn't a slave"
            - stop
        - if <[slave].has_flag[slave_timer]> && !<[slave].has_flag[owner]> && !<[slave].in_group[slave]>:
            - narrate "<red> ERROR: This user isn't a <gold>Godvip <red>or a <blue>SupremeWarden <red>slave"
            - stop
        - if <[action]> == start:
            - if <[slave].flag[owner]> != <player.name>:
                - narrate "<red> ERROR: This slave isn't yours"
                - stop
            - narrate "<green> Starting to force the slave <red><[slave].name> to stay within <yellow>10 <green>blocks"
            - narrate "<yellow> Be aware. <green>It will work until you or the slave are offline."
            - narrate "<red> You are now forced to stay with your <gold>owner" targets:<[slave]>
            - while <player.is_online> && <[slave].is_online> && <[slave].has_flag[owner]> && <[slave].in_group[slave]> && !<[slave].has_flag[slave_timer]>:
                - if <player.location.points_between[<[slave].location>].size> > <[slave].flag[owner_block_limit]>:
                    - teleport <[slave]> <player.location>
                - wait 1s
            - if <[slave].has_flag[jail_owner]>:
                - define jail_spawn <[slave].flag[jail_owner]>_spawn
                - flag <[slave]> owner:<[slave].flag[jail_owner]>
                - flag <[slave]> owner_block_limit:!
                - flag <[slave]> slave_timer:120
                - teleport <[slave]> <location[<[jail_spawn]>]>
                - flag <[slave]> jail_owner:!
            - stop
        - if <[action]> == limit && <context.args.size> == 3:
            - define limit_number <context.args.get[3]>
            - if <[limit_number]> < 10 && <[limit_number]> > 30:
                - narrate "<red> ERROR: The space limit between you and your slave only can be set between <yellow>10-30 <red>blocks"
                - stop
            - flag <[slave]> owner_block_limit:<[limit_number]>
            - narrate "<green> The space between your slave and you will be <yellow><[limit_number]> <green>blocks"
            - stop
        - if <[action]> == control && <player.in_group[supremewarden]> || <player.is_op||context_server>:
            - if !<[slave].has_flag[slave_timer]> && !<[slave].has_flag[owner]> && !<[slave].in_group[slave]>:
                - narrate "<red> ERROR: This user isn't a slave"
                - stop
            - if <[slave].flag[owner]> == <player.name>:
                - flag <[slave]> owner:<[slave].flag[jail_owner]>
                - flag <[slave]> jail_owner:!
                - narrate "<green> You stopped getting the <red>slave <green>with you"
                - stop
            - flag <[slave]> jail_owner:<[slave].flag[owner]>
            - flag <[slave]> owner:<player.name>
            - flag <[slave]> owner_block_limit:10
            - flag <[slave]> slave_timer:!
            - narrate "<green> You started getting the <red>slave <green>with you"
            - stop
        - if <[action]> == free:
            - if <[slave].has_flag[jail_owner]>:
                - define jail_slaves <[slave].flag[jail_owner]>_slaves
                - flag server <[jail_slaves]>:<-:<[username]>
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