# /soldiers Usage
# /soldiers add <jailname> <username> - Adds a soldier to a jail.
# /soldiers remove <jailname> <username> - Removes a soldier to a jail.
# /soldiers list <jailname> soldiers <#> - List the soldiers in this jail.
# /soldiers list <jailname> wanteds <#> - List the wanted players in this jail.
# /soldiers wanted <jailname> add <#> - Add a wanted from this jail.
# /soldiers wanted <jailname> remove <#> - Remove a wanted from this jail.
# /soldiers jailstick - Replaces your hand with a jailstick.
# /soldiers default <jailname> - Sets the default jail of the Soldiers.
# Additional notes
# - A SupremeWarden must add himself to a jail as a soldier
# - If a Soldier/SupremeWarden with a Jail linked kills a Insurgent, he revives in jail
# Player flags created here
# - slave_timer [Used in Jails, Slaves]
# - owner [Used in Jails, Slaves]
# - soldier_jail [Used in Jails]
# Notables created here
# - jail_<name>_soldiers [Used in Jails]
# Permissions used here
# - soldier.jail

Command_Soldier:
    type: command
    debug: false
    name: soldiers
    description: Minecraft Soldiers (Jail) system.
    usage: /soldiers
    tab complete:
        - if !<player.is_op||<context.server>> && !<player.in_group[supremewarden]> && !<player.has_permission[soldier.jail]>:
            - stop
        - choose <context.args.size>:
            - case 0:
                - determine <list[add|default|remove|list|wanted|jailstick]>
            - case 1:
                - if "!<context.raw_args.ends_with[ ]>":
                    - determine <list[add|default|remove|list|wanted|jailstick].filter[starts_with[<context.args.first>]]>
                - else:
                    - if <server.has_flag[prison_jails]> && <context.args.get[1]> != jailstick:
                        - determine <server.flag[prison_jails].parse[after[jail_]]>
            - case 2:
                - if <server.has_flag[prison_jails]>:
                    - if "!<context.raw_args.ends_with[ ]>":
                            - determine <server.flag[prison_jails].parse[after[jail_]]>
                    - else:
                        - if <context.args.get[1]> == list:
                            - determine <list[soldiers|wanteds]>
                        - if <context.args.get[1]> == wanted:
                            - determine <list[add|remove]>
                        - else:
                            - determine <server.online_players.parse[name]>
            - case 3:
                - if "!<context.raw_args.ends_with[ ]>":
                    - if <context.args.get[1]> == list:
                        - determine <list[soldiers|wanteds]>
                    - if <context.args.get[1]> == wanted:
                        - determine <list[add|remove]>
                    - else:
                        - determine <server.online_players.parse[name]>
                - else:
                    - if <context.args.get[1]> == list:
                        - determine <server.flag[prison_jails].size.div[10].truncate>
                    - if <context.args.get[1]> == wanted:
                        - determine <server.online_players.parse[name]>
    script:
        - if !<player.is_op||<context.server>> && !<player.in_group[supremewarden]> && !<player.has_permission[soldier.jail]>:
            - narrate "<red>You do not have permission for that command."
            - stop
        - define action <context.args.get[1]>
        - if <[action]> == jailstick:
            - give jailstick to:<player.inventory>
            - stop
        - if <context.args.size> < 2:
            - goto syntax_error
        - define name <context.args.get[2]>
        - define jail_name jail_<[name]>
        - if <[jail_name].ends_with[_spawn]>:
            - narrate "<red> ERROR: Invalid jail name. Please don't use _spawn in your jail name."
            - stop
        - if <cuboid[<[jail_name]>]||null> == null:
            - narrate "<red> ERROR: Jail <[name]> doesn't exist."
            - stop
        - if <[action]> == default:
            - if !<player.is_op||<context.server>> && !<player.in_group[supremewarden]>:
                - narrate "<red>You do not have permission for that command."
                - stop
            - flag server default_soldier_jail:<[jail_name]>
            - narrate "<blue> <[name]> <green>is now the default jail of the soldiers!"
            - stop
        - if <[action]> == list:
            - if <context.args.size> < 4:
                - goto syntax_error
            - define target <context.args.get[3]>
            - if <[target]> == soldiers:
                - if !<player.is_op||<context.server>> && !<player.in_group[supremewarden]>:
                    - narrate "<red>You do not have permission for that command."
                    - stop
                - define list_page <context.args.get[4]>
                - run List_Task_Script def:<[jail_name]>|Soldier|<[list_page]>
                - stop
            - if <[target]> == wanteds:
                - define list_page <context.args.get[4]>
                - run List_Task_Script def:<[jail_name]>|Wanted|<[list_page]>
                - stop
        - if <[action]> == wanted:
            - if !<player.is_op||<context.server>> && !<player.in_group[supremewarden]>:
                - narrate "<red>You do not have permission for that command."
                - stop
            - if <context.args.size> < 4:
                - goto syntax_error
            - define secondary_action <context.args.get[3]>
            - if <[secondary_action]> == add || <[secondary_action]> == remove:
                - define username <server.match_player[<context.args.get[4]>]||null>
                - if <[username]> == null:
                    - narrate "<red> ERROR: Invalid player username OR the player is offline."
                    - stop
                - define jail_wanteds <[jail_name]>_wanteds
                - if <[secondary_action]> == add:
                    - if <server.has_flag[<[jail_wanteds]>]> && <server.flag[<[jail_wanteds]>].find[<[username]>]> != -1:
                        - narrate "<red> ERROR: The player is already a wanted of this jail"
                        - stop
                    - flag server <[jail_wanteds]>:|:<[username]>
                    - narrate "<blue> <[username].name> <green>added to the wanted list!"
                    - stop
                - if <[secondary_action]> == remove:
                    - if <server.has_flag[<[jail_wanteds]>]> && <server.flag[<[jail_wanteds]>].find[<[username]>]> == -1:
                        - narrate "<red> ERROR: The player is not a wanted of this jail"
                        - stop
                    - flag server <[jail_wanteds]>:<-:<[username]>
                    - narrate "<blue> <[username].name> <green>removed from the wanted list!"
                    - stop
        - if <[action]> == add || <[action]> == remove:
            - if !<player.is_op||<context.server>> && !<player.in_group[supremewarden]>:
                - narrate "<red>You do not have permission for that command."
                - stop
            - if <context.args.size> < 3:
                - goto syntax_error
            - define username <server.match_player[<context.args.get[3]>]||null>
            - if <[username]> == null:
                - narrate "<red> ERROR: Invalid player username OR the player is offline."
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
        - mark syntax_error
        - narrate "<yellow>#<red> ERROR: Syntax error. Follow the command syntax:"
        - narrate "<yellow>-<red> To add a soldier to a jail: /soldiers add <yellow>jailname username"
        - narrate "<yellow>-<red> To remove a soldier from a jail: /soldiers remove <yellow>jailname username"
        - narrate "<yellow>-<red> To show a list of soldiers from a jail: /soldiers list <yellow>jailname <yellow>number"
        - narrate "<yellow>-<red> To show a list of wanteds from a jail: /soldiers wanted <yellow>jailname <yellow>number"
        - narrate "<yellow>-<red> To get a jailstick: /soldiers jailstick"

jailstick:
    type: item
    debug: false
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
                - if !<player.in_group[soldier]> && !<player.in_group[general]>:
                    - narrate "<red>ERROR: What are you trying to do? You can't caught someone. <blue>Only SOLDIERS can!"
                    - stop
            - if !<script[Soldier_Script].cooled_down[<player>]>:
                - stop
            - if !<player.has_flag[soldier_jail]>:
                - if <player.has_permission[soldier.jail]>:
                    - if !<server.has_flag[default_soldier_jail]>:
                        - narrate "<red> ERROR: No default Jail set for soldiers"
                        - narrate "<white> Please tell a Supreme Warden or an OP to set the default jail of the Soldiers"
                        - stop
                    - flag <player> soldier_jail:<server.flag[default_soldier_jail]>
                    - goto default_soldier
                - narrate "<red> ERROR: You don't belong to a Jail!"
                - stop
            - mark default_soldier
            - define jail <player.flag[soldier_jail]>
            - if <context.entity.in_group[slave]>:
                - if !<context.entity.has_flag[slave_timer]>:
                    - narrate "<red> ERROR: This slave is property of someone!"
                    - stop
                - if <context.entity.flag[owner]> == <[jail]>:
                    - flag <context.entity> slave_timer:+:<script[Slaves_Config].data_key[slave_timer]>
                    - narrate "<green> Slave: <red><context.entity.name> <green>time extended by <blue>2 hours"
                    - narrate "<red> Your time got extended by <yellow>2 hours <red>SLAVE" targets:<context.entity>
                - cooldown 10s script:Soldier_Script
                - stop
            - if <context.entity.in_group[insurgent]> || <context.entity.in_group[civilian]> || <context.entity.in_group[default]> || <context.entity.in_group[vip]> || <context.entity.in_group[ultravip]> || <context.entity.in_group[supremevip]> || <context.entity.in_group[godvip]>:
                - define jail_wanted <[jail]>_wanteds
                - narrate "<red><context.entity.name> <green>was added to the <yellow>WANTED <green>list"
                - flag server <[jail_wanted]>:|:<context.entity>
                - cooldown 10s script:Soldier_Script
        on player kills player:
            - if <context.entity.in_group[slave]>:
                - stop
            - if !<context.damager.has_flag[soldier_jail]>:
                - stop
            - if !<context.damager.is_op> && !<context.damager.in_group[supremewarden]> && !<context.damager.in_group[soldier]> && !<context.damager.in_group[general]>:
                - stop
            - define jail <context.damager.flag[soldier_jail]>
            - define jail_slaves <[jail]>_slaves
            - define jail_wanted <[jail]>_wanteds
            - if !<context.entity.in_group[insurgent]> && !<server.has_flag[<[jail_wanted]>]>:
                - stop
            - if <server.has_flag[<[jail_wanted]>]>:
                - if <server.flag[<[jail_wanted]>].find[<context.entity>]>:
                    - flag server <[jail_wanted]>:<-:<context.entity>
            - if <context.entity.groups.size> == 1 && <context.entity.groups.first> == default:
                - execute as_server "lp user <context.entity.name> parent set slave" silent
            - else:
                - execute as_server "lp user <context.entity.name> parent add slave" silent
            - flag <context.entity> owner:<[jail]>
            - flag <context.entity> slave_timer:<script[Slaves_Config].data_key[slave_timer]>
            - flag server <[jail_slaves]>:|:<context.entity>
            - narrate "<green> Good job Soldier! You caught <red><context.entity.name> <green>breaking the rules." targets:<context.damager>
            - narrate "<green> Welcome to the jail <red>SLAVE!"