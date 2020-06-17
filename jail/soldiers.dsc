# /soldier Usage
# /soldier add <jailname> <username> - Adds a soldier to a jail.
# /soldier remove <jailname> <username> - Removes a soldier to a jail.
# /soldier list <jailname> <#> - List the soldiers in this jail.
# /soldier wanted <jailname> <#> - List the wanted players in this jail.
# /soldier jailstick - Replaces your hand with a jailstick.
# Additional notes
# - A SupremeWarden must add himself to a jail as a soldier
# - If a Soldier/SupremeWarden with a Jail linked kills a Insurgent, he revives in jail
# Player flags created here
# - slave_timer [Used in Jails, Slaves]
# - owner [Used in Jails, Slaves]
# - soldier_jail [Used in Jails]
# Notables created here
# - jail_<name>_soldiers [Used in Jails]

Command_Soldier:
    type: command
    debug: false
    name: soldiers
    description: Minecraft Soldiers (Jail) system.
    usage: /soldiers
    script:
        - if !<player.is_op||<context.server>> && !<player.in_group[supremewarden]>:
                - narrate "<red>You do not have permission for that command."
                - stop
        - define action <context.args.get[1]>
        - if <[action]> == jailstick:
            - equip <player> hand:jailstick
            - stop
        - if <context.args.size> < 3:
            - narrate "<yellow>#<red> ERROR: Not enough arguments."
            - narrate  "<yellow>-<red> To add a soldier to a jail: /soldiers add <yellow>jailname username"
            - narrate  "<yellow>-<red> To remove a soldier from a jail: /soldiers remove <yellow>jailname username"
            - narrate "<yellow>-<red> To show a list of soldiers from a jail: /soldiers list <yellow>jailname <yellow>number"
            - narrate "<yellow>-<red> To show a list of wanteds from a jail: /soldiers wanted <yellow>jailname <yellow>number"
            - stop
        - define name <context.args.get[2]>
        - define jail_name jail_<[name]>
        - if <[jail_name].ends_with[_spawn]>:
            - narrate "<red> ERROR: Invalid jail name. Please don't use _spawn in your jail name."
            - stop
        - if <[action]> == list && <context.args.size> == 3:
            - define list_page <context.args.get[3]>
            - run List_Task_Script def:<[jail_name]>|Soldier|<[list_page]>
            - stop
        - if <[action]> == wanted && <context.args.size> == 3:
            - define list_page <context.args.get[3]>
            - run List_Task_Script def:<[jail_name]>|Wanted|<[list_page]>
            - stop
        - if <[action]> == add || <[action]> == remove:
            - if <cuboid[<[jail_name]>]||null> == null:
                - narrate "<red> ERROR: Jail <[name]> doesn't exist."
                - stop
            - define username <server.match_player[<context.args.get[3]>]||null>
            - if <[username]> == null:
                - narrate "<red> ERROR: Invalid player username."
                - stop
            - if !<[username].in_group[soldier]> && !<[username].in_group[supremewarden]> && !<player.is_op||<context.server>>:
                - narrate "<red> ERROR: This player isn't a soldier or a SupremeWarden."
                - stop
            - define jail_soldiers <[jail_name]>_soldiers
            - if <[action]> == add:
                - if <[username].has_flag[soldier_jail]>:
                    - narrate "<red> ERROR: This soldier already belongs to a Jail"
                    - stop
                - flag <[username]> soldier_jail:<[jail_name]>
                - flag server <[jail_soldiers]>:|:<[username]>
                - narrate "<green> Soldier <blue><[username].name> <green>added!"
            - if <[action]> == remove:
                - flag <[username]> soldier_jail:!
                - flag server <[jail_soldiers]>:<-:<[username]>
                - narrate "<green> Soldier <blue><[username].name> <green>removed!"
            - stop
        - narrate "<yellow>#<red> ERROR: Syntax error. Follow the command syntax:"
        - narrate "<yellow>-<red> To add a soldier to a jail: /soldiers add <yellow>jailname username"
        - narrate "<yellow>-<red> To remove a soldier from a jail: /soldiers remove <yellow>jailname username"
        - narrate "<yellow>-<red> To show a list of soldiers from a jail: /soldiers list <yellow>jailname <yellow>number"
        - narrate "<yellow>-<red> To show a list of wanteds from a jail: /soldiers wanted <yellow>jailname <yellow>number"
        - narrate "<yellow>-<red> To get a jailstick: /soldiers jailstick"

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
    debug: false
    events:
        on player right clicks player with:jailstick:
            - if !<player.is_op||<context.server>> && !<player.in_group[supremewarden]>:
                - if !<player.in_group[soldier]> || !<player.has_flag[soldier_jail]>:
                    - narrate "<red>ERROR: What are you trying to do? You can't caught someone. <blue>Only JAIL SOLDIERS can!"
                    - stop
            - if !<script[Soldier_Script].cooled_down[<player>]>:
                - stop
            - if !<player.has_flag[soldier_jail]>:
                - narrate "<red> ERROR: Please add yourself to the soldiers of the jail"
                - stop
            - define jail <player.flag[soldier_jail]>
            - if <context.entity.in_group[slave]>:
                - if !<context.entity.has_flag[slave_timer]>:
                    - narrate "<red> ERROR: This slave is property of someone!"
                - if <context.entity.flag[owner]> == <[jail]>:
                    - flag <context.entity> slave_timer:+:120
                    - narrate "<green> Slave: <red><context.entity.name> <green>time extended by <blue>2 hours"
                    - narrate "<red> Your time got extended by <yellow>2 hours <red>SLAVE" targets:<context.entity>
                - cooldown 10s script:Soldier_Script
                - stop
            - if <context.entity.in_group[insurgent]> || <context.entity.in_group[civilian]> || <context.entity.in_group[default]>:
                - define jail_wanted <[jail]>_wanteds
                - narrate "<red><context.entity.name> <green>was added to the <yellow>WANTED <green>list"
                - flag server <[jail_wanted]>:|:<context.entity>
                - cooldown 10s script:Soldier_Script
        on player kills player:
            - if <context.entity.in_group[slave]>:
                - stop
            - if !<context.damager.has_flag[soldier_jail]>:
                - stop
            - if !<context.damager.in_group[supremewarden]> && !<context.damager.in_group[soldier]>:
                - stop
            - define jail <context.damager.flag[soldier_jail]>
            - define jail_slaves <[jail]>_slaves
            - define jail_wanted <[jail]>_wanteds
            - if !<context.entity.in_group[insurgent]> && !<server.has_flag[<[jail_wanted]>]>:
                - stop
            - if <server.has_flag[<[jail_wanted]>]>:
                - if <server.flag[<[jail_wanted]>].contains[<context.entity>]>:
                    - flag server <[jail_wanted]>:<-:<context.entity>
            - execute as_server "lp user <context.entity.name> parent add slave" silent
            - flag <context.entity> owner:<[jail]>
            - flag <context.entity> slave_timer:120
            - flag server <[jail_slaves]>:|:<context.entity>
            - narrate "<green> Good job Soldier! You caught <red><context.entity.name> <green>breaking the rules." targets:<context.damager>
            - narrate "<green> Welcome to the jail <red>SLAVE!"