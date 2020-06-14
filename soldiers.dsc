# /soldier Usage
# /soldier add <jailname> <username> - Adds a soldier to a jail.
# /soldier remove <jailname> <username> - Removes a soldier to a jail.
# /soldier list <jailname> <#> - List the soldiers in this jail.
# /soldier jailstick - Replaces your hand with a jailstick.
# Player flags created here
# - slave_timer [Used in Jails, Slaves] [WIP]
# - owner [Used in Jails, Slaves] [WIP]
# - soldier_jail [Used in Jails]
# Notables created here
# - jail_<name>_soldiers [Used in Jails]

Command_Soldier:
    type: command
    name: soldiers
    description: Minecraft Soldiers (Jail) system.
    usage: /soldiers
    script:
        - if !<player.is_op||<context.server>>:
            - if !<player.in_group[supremewarden]>:
                - narrate "<red>You do not have permission for that command."
                - stop
        - define action <context.args.get[1]>
        - if <[action]> == jailstick:
            - equip <player> hand:jailstick
            - stop
        - if <context.args.size> < 3:
            - narrate "<red> ERROR: Not enough arguments."
            - narrate  "<red> To add a soldier to a jail: /soldiers add <yellow>jailname username"
            - narrate  "<red> To remove a soldier from a jail: /soldiers remove <yellow>jailname username"
            - stop
        - define name <context.args.get[2]>
        - define jail_name "jail_<[name]>"
        - if <[jail_name].ends_with[_spawn]>:
            - narrate "<red> ERROR: Invalid jail name. Please don't use _spawn in your jail name."
            - stop
        - if <[action]> == list && <context.args.size> == 3:
            - define list_page <context.args.get[3]>
            - if <[list_page].is_integer>:
                - define jail_soldiers <server.flag[<[jail_name]>_soldiers]||null>
                - if <[jail_soldiers]> == null || <[jail_soldiers].is_empty>:
                    - narrate "<green> Jail <blue><[name]> <green>have <blue>0 <green>soldiers."
                    - stop
                - narrate "<green> Jail <blue><[name]> <green>have <blue><[jail_soldiers].size> <green>soldiers."
                - if <[jail_soldiers].size> > 10:
                    - if <[list_page]> > <[jail_soldiers].size.div[10]>:
                        - narrate "<red> ERROR! Page number invalid."
                        - stop
                    - narrate "<green> Page [<[list_page]>/<[jail_soldiers].size.div[10].truncate>]"
                    - flag player soldier_num_min:<[list_page].mul[10]>
                    - flag player soldier_num_max:<[list_page].add[1].mul[10]>
                    - if <[list_page]> != 0 && <player.flag[soldier_num_max].div[<[jail_soldiers].size>]> != 1:
                        - flag player soldier_num_max:<[jail_soldiers].size>
                    - if <[list_page]> > 0:
                        - flag player soldier_num_min:++
                    - foreach <[jail_soldiers].get[<player.flag[soldier_num_min]>].to[<player.flag[soldier_num_max]>]> as:soldier:
                        - if <[loop_index]> == 10:
                            - narrate "<green> Soldier <[loop_index]>: <blue><[soldier].name>"
                            - foreach stop
                        - narrate "<green> Soldier <[list_page]><[loop_index]>: <blue><[soldier].name>"
                    - flag player soldier_num_min:!
                    - flag player soldier_num_max:!
                - if <[jail_soldiers].size> <= 10:
                    - foreach <[jail_soldiers]> as:soldier:
                        - narrate "<green> Soldier <[loop_index]>: <blue><[soldier].name>"
                - stop
        - if <[action]> == add || <[action]> == remove:
            - if <cuboid[<[jail_name]>]||null> == null:
                - narrate "<red> ERROR: Jail <[name]> doesn't exist."
                - stop
            - define username <server.match_player[<context.args.get[3]>]||null>
            - if <[username]> == null:
                - narrate "<red> ERROR: Invalid player username."
                - stop
            - if !<[username].in_group[soldier]>:
                - narrate "<red> ERROR: This player isn't a soldier."
                - stop
            - define jail_soldiers "<[jail_name]>_soldiers"
            - if <[action]> == add:
                - flag <[username]> soldier_jail:<[jail_name]>
                - flag server <[jail_soldiers]>:|:<[username]>
                - narrate "<green> Soldier <blue><[username].name> <green>added!"
            - if <[action]> == remove:
                - flag <[username]> soldier_jail:!
                - flag server <[jail_soldiers]>:<-:<[username]>
                - narrate "<green> Soldier <blue><[username].name> <green>removed!"
            - stop
        - narrate "<red> ERROR: Syntax error. Follow the command syntax:"
        - narrate  "<red> To add a soldier to a jail: /soldiers add <yellow>jailname username"
        - narrate  "<red> To remove a soldier from a jail: /soldiers remove <yellow>jailname username"
        - narrate "<red> To get a jailstick: /soldiers jailstick"

jailstick:
    type: item
    material: stick
    mechanisms:
        hides: enchants
    enchantments:
        - unbreaking:1
        - vanishing_curse
    display name: <blue>Jailstick
    lore:
        - <gray>Defend your country <blue>SOLDIER!
        - <gray>Use this to make someone a slave
        - <gray>in the jail that you belong.
        - <red>Lost on death

Soldier_Script:
    type: world
    events:
        on player right clicks entity with:jailstick:
            - narrate Hi


