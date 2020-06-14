# /soldier Usage
# /soldier add <jailname> <username> - Adds a soldier to a jail.
# /soldier remove <jailname> <username> - Removes a soldier to a jail.
# /soldier jailstick - Replaces your hand with a jailstick.

Command_Soldier:
    type: command
    name: soldiers
    description: Minecraft Soldiers (Jail) system.
    usage: /soldiers
    script:
        - if !<player.is_op||<context.server>>:
            - if <player.groups.find[supremewarden]> == -1:
                - narrate "<red>You do not have permission for that command."
                - stop
        - define action <context.args.get[1]>
        - if <[action]> == jailstick:
            - equip <player> hand:jailstick
            - stop
        - if <context.args.size> < 3:
            - narrate "<red> ERROR: Not enough arguments."
            - narrate  "<red> To add a soldier to a jail: /soldier add <yellow>jailname username"
            - narrate  "<red> To remove a soldier from a jail: /soldier remove <yellow>jailname username"
            - stop
        - define name <context.args.get[2]>
        - define jail_name "jail_<[name]>"
        - if <[jail_name].ends_with[_spawn]>:
            - narrate "<red> ERROR: Invalid jail name. Please don't use _spawn in your jail name."
            - stop
        - if <[action]> == add || <[action]> == remove:
            - if <cuboid[<[jail_name]>]||null> == null:
                - narrate "<red> ERROR: Jail <[name]> doesn't exist."
                - stop
            - define username <context.args.get[3]>
            - if <player[<[username]>]||null> == null:
                - narrate "<red> ERROR: Invalid player username."
                - stop
            - if <player[<[username]>].groups.find[soldier]> == -1:
                - narrate "<red> ERROR: This player isn't a soldier."
                - stop
            - if <[action]> == add:
                - flag <player[<[username]>]> soldier_jail:<[jail_name]>
                - narrate "<green> Soldier <blue><[username]> <green>added!"
            - if <[action]> == remove:
                - flag <player[<[username]>]> soldier_jail:!
                - narrate "<green> Soldier <blue><[username]> <green>removed!"
            - stop
        - narrate "<red> ERROR: Syntax error. Follow the command syntax:"
        - narrate  "<red> To add a soldier to a jail: /soldier add <yellow>jailname username"
        - narrate  "<red> To remove a soldier from a jail: /soldier remove <yellow>jailname username"
        - narrate "<red> To get a jailstick: /soldier jailstick"

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

