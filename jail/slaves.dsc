# /slaves Usage
# /slaves spawn <jailname> - Sets the spawn point of the slave in the player position.
# /slaves list <jailname> <#> - List the slaves in this jail.
# /slaves add <jailname> <username> - Adds a slaves to a jail.
# /slaves remove <jailname> <username> - Removes a slaves from a Jail.
# /slaves pickaxe - Replaces your hand with a slave pickaxe.
# Notables created here
# - jail_<name>_spawn [Used in Jails]

Command_Slaves:
    type: command
    debug: false
    name: slaves
    description: Minecraft slave system.
    usage: /slaves
    script:
        - if !<player.is_op||<context.server>> && !<player.in_group[supremewarden]>:
                - narrate "<red>You do not have permission for that command."
                - stop
        - if <context.args.size> == 1 && <context.args.get[1]> == pickaxe:
            - equip <player> hand:slave_pickaxe
            - stop
        - if <context.args.size> < 2:
            - narrate "<yellow>#<red> ERROR: Not enough arguments. Follow the command syntax:"
            - narrate "<yellow>-<red> To set the spawn of a jail: /slaves spawn <yellow>jailname"
            - narrate "<yellow>-<red> To add a slave to a jail: /slaves add <yellow>jailname <yellow>username"
            - narrate "<yellow>-<red> To remove a slave from a jail: /slaves remove <yellow>jailname <yellow>username"
            - narrate "<yellow>-<red> To show a list of slaves from a jail: /slaves list <yellow>jailname <yellow>number"
            - narrate "<yellow>-<red> To get a slave pickaxe /slave pickaxe"
            - stop
        - define action <context.args.get[1]>
        - define name <context.args.get[2]>
        - define jail_name jail_<[name]>
        - if <cuboid[<[jail_name]>]||null> == null:
            - narrate "<red> Jail <[name]> doesn't exist."
            - stop
        - if <[action]> == add && <player.is_op||<context.server>>:
            - define username <server.match_player[<context.args.get[3]>]||null>
            - if <[username]> == null:
                - narrate "<red> ERROR: Invalid player username OR the player is offline."
                - stop
            - if <[username].in_group[slave]>:
                - narrate "<red> ERROR: This player is already a slave."
                - stop
            - define jail_slaves <[jail_name]>_slaves
            - define jail_spawn <[jail_name]>_spawn
            - if !<location[<[jail_spawn]>]||null> == null:
                - narrate "<red> ERROR: Please set the jail spawn with /slaves spawn <yellow>jailname <red>while standing inside the jail"
                - stop
            - flag server <[jail_slaves]>:|:<[username]>
            - flag <[username]> owner:<[jail_name]>
            - flag <[username]> slave_timer:120
            - flag <[username]> jail_owner:!
            - flag <[username]> owner_block_limit:!
            - execute as_server "lp user <[username].name> parent add slave" silent
            - if <[username].is_online>:
                - teleport <[username]> <location[<[jail_spawn]>]>
                - narrate "<green> Welcome to the jail <red>SLAVE!" targets:<[username]>
            - narrate "<green> Slave <blue><[username].name> <green>added to the Jail!"
            - stop
        - if <[action]> == spawn:
            - if !<cuboid[<[jail_name]>].contains_location[<player.location>]>:
                - narrate "<red> ERROR: Stand on the jail boundary to set the slave spawn."
                - stop
            - note <player.location> as:<[jail_name]>_spawn
            - narrate "<green> Slave spawn set for the jail <[name]>."
            - stop
        - if <[action]> == list && <context.args.size> == 3:
            - define list_page <context.args.get[3]>
            - run List_Task_Script def:<[jail_name]>|Slave|<[list_page]>
            - stop
        - if <[action]> == remove && <context.args.size> == 3:
            - define username <server.match_player[<context.args.get[3]>]||null>
            - if <[username]> == null:
                - narrate "<red> ERROR: Invalid player username OR the player is offline."
                - stop
            - if !<[username].in_group[slave]>:
                - narrate "<red> ERROR: This player isn't a slave."
                - stop
            - define jail_slaves <[jail_name]>_slaves
            - flag server <[jail_slaves]>:<-:<[username]>
            - flag <[username]> owner:!
            - flag <[username]> slave_timer:!
            - flag <[username]> jail_owner:!
            - flag <[username]> owner_block_limit:!
            - execute as_server "lp user <[username].name> parent remove slave" silent
            - narrate "<green> Slave <blue><[username].name> <green>removed!"
            - stop
        - narrate "<yellow>#<red> ERROR: Syntax error. Follow the command syntax:"
        - narrate "<yellow>-<red> To set the spawn of a jail: /slaves spawn <yellow>jailname"
        - narrate "<yellow>-<red> To add a slave to a jail: /slaves add <yellow>jailname <yellow>username"
        - narrate "<yellow>-<red> To remove a slave from a jail: /slaves remove <yellow>jailname <yellow>username"
        - narrate "<yellow>-<red> To show a list of slaves from a jail: /slaves list <yellow>jailname <yellow>number"
        - narrate "<yellow>-<red> To get a slave pickaxe /slaves pickaxe"

Slave_Script:
    type: world
    debug: false
    events:
        on player exits notable cuboid:
            - if !<context.cuboids.parse[notable_name].filter[starts_with[jail]].is_empty>:
                - define jail <context.cuboids.parse[notable_name].filter[starts_with[jail]].first>
                - if <player.in_group[slave]> && <player.has_flag[slave_timer]>:
                    - define jail_spawn <[jail]>_spawn
                    - wait 1s
                    - teleport <player> <location[<[jail_spawn]>]>
                    - hurt <player> 5
                    - narrate "<red> You tried to escape... But you got caught and punched by the guards."
        after player respawns:
            - if <player.in_group[slave]> && <player.has_flag[owner]> && <player.has_flag[slave_timer]>:
                - define owner_name_spawn <player.flag[owner]>_spawn
                - teleport <player> <location[<[owner_name_spawn]>]>
                - narrate "<red> You died but you're a slave. Now you're with your owner."
            - if <player.in_group[slave]> && <player.has_flag[owner]> && !<player.has_flag[slave_timer]>:
                - define owner <server.match_player[<player.flag[owner]>]||null>
                - if <[owner]> != null:
                    - teleport <player> <[owner].location>
                    - narrate "<red> You died but you're a slave. Now you're with your owner."
        on system time minutely every:10:
            - foreach <server.online_players> as:server_player:
                - if <[server_player].in_group[slave]>:
                    - if <[server_player].has_flag[slave_timer]> && <[server_player].has_flag[owner]>:
                        - define owner <[server_player].flag[owner]>
                        - flag <[server_player]> slave_timer:-:10
                        - define slave_timer <[server_player].flag[slave_timer]>
                        - if <[slave_timer]> == 0.0:
                            - execute as_server "slaves jail <[owner].after[jail_]> remove <[server_player].name>" silent
                            - narrate "<green> You are free <red>SLAVE" targets:<[server_player]>
        after player join:
            - if <player.in_group[slave]> && <player.has_flag[owner]> && <player.has_flag[slave_timer]>:
                - teleport <player> <location[<player.flag[owner]>_spawn]>

slave_pickaxe:
    type: item
    material: iron_pickaxe
    mechanisms:
        repair_cost: 99
        hides: attributes|enchants
        enchantments: unbreaking,3
    display name: <red>Slave Pickaxe
    lore:
        - <gray>Mine with this
        - <gray>pickaxe... <red>SLAVE!
        - <gray>Your resources are
        - <gray>the jail resources.