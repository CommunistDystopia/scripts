# +----------------------
# |
# | S O L D I E R S
# |
# | Have soldiers to send rule-breakers to the jail.
# |
# +----------------------
#
# @author devnodachi
# @date 2020/08/02
# @denizen-build REL-1714
# @dependency devnodachi/jails
#
# Commands
# Soldiers Admin
# /soldiersadmin Usage
# /soldiers add <jailname> <username> - Adds a soldier to a jail.
# /soldiers remove <jailname> <username> - Removes a soldier to a jail.
# /soldiers list <jailname> <#> - List the soldiers in this jail.
# /soldiers wanted <jailname> list <#> - List the wanted players in this jail.
# /soldiers wanted <jailname> add <username> - Add a wanted from this jail.
# /soldiers wanted <jailname> remove <username> - Remove a wanted from this jail.
# /soldiers default <jailname> - Sets the default jail of the Soldiers.
# /soldiers jailstick - Give a jailstick.
# /soldiers sword - Give a guard sword.
# Soldiers
# /soldiers Usage
# /soldiers wanted <jailname> list <#> - List the wanted players in this jail.
# /soldiers wanted <jailname> add <username> - Add a wanted from this jail.
# /soldiers jailstick - Give a jailstick.
# /soldiers sword - Give a guard sword.
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

Command_Soldier_Admin:
    type: command
    debug: false
    name: soldiersadmin
    description: Minecraft Soldiers Admin (Jail) system.
    usage: /soldiersadmin
    aliases:
    - sa
    tab complete:
        - if !<player.is_op||<context.server>> && !<player.in_group[supremewarden]>:
            - stop
        - choose <context.args.size>:
            - case 0:
                - determine <list[add|default|remove|list|wanted]>
            - case 1:
                - if "!<context.raw_args.ends_with[ ]>":
                    - determine <list[add|default|remove|list|wanted].filter[starts_with[<context.args.first>]]>
                - else:
                    - determine <server.flag[prison_jails].parse[after[jail_]]>
            - case 2:
                - if <server.has_flag[prison_jails]>:
                    - if "!<context.raw_args.ends_with[ ]>":
                        - determine <server.flag[prison_jails].parse[after[jail_]]>
                    - else:
                        - if <context.args.get[1]> == list:
                            - determine 0
                        - if <context.args.get[1]> == wanted:
                            - determine <list[add|remove|list]>
                        - else:
                            - determine <server.online_players.parse[name]>
            - case 3:
                - if "!<context.raw_args.ends_with[ ]>":
                    - if <context.args.get[1]> == list:
                        - determine 0
                    - if <context.args.get[1]> == wanted:
                        - determine <list[add|remove|list]>
                    - else:
                        - determine <server.online_players.parse[name]>
                - else:
                    - if <context.args.get[1]> == list:
                        - determine <server.flag[prison_jails].size.div[10].truncate>
                    - if <context.args.get[1]> == wanted:
                        - if <context.args.get[3]> == add || <context.args.get[3]> == remove:
                            - determine <server.online_players.parse[name]>
                        - if <context.args.get[3]> == list:
                            - determine 0
    script:
        - if !<player.is_op||<context.server>> && !<player.in_group[supremewarden]>:
            - narrate "<red>You do not have permission for that command."
            - stop
        - if !<player.has_flag[soldier_jail]>:
            - if !<server.has_flag[default_soldier_jail]>:
                - narrate "<red> ERROR: No default Jail set for soldiers"
                - narrate "<white> Please tell a Supreme Warden or an OP to set the default jail of the Soldiers"
                - stop
            - flag <player> soldier_jail:<server.flag[default_soldier_jail]>
            - flag server <server.flag[default_soldier_jail]>_soldiers:|:<player>
        - define action <context.args.get[1]>
        - if <[action]> == sword:
            - give guard_sword to:<player.inventory>
            - stop
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
            - flag server default_soldier_jail:<[jail_name]>
            - narrate "<blue> <[name]> <green>is now the default jail of the soldiers!"
            - stop
        - if <[action]> == list:
            - if <context.args.size> < 3:
                - goto syntax_error
            - define list_page <context.args.get[3]>
            - run List_Task_Script def:server|<[jail_name]>_soldiers|Soldier|<[list_page]>|true
            - stop
        - if <[action]> == wanted:
            - if !<player.is_op||<context.server>> && !<player.in_group[supremewarden]>:
                - narrate "<red>You do not have permission for that command."
                - stop
            - if <context.args.size> < 4:
                - goto syntax_error
            - define secondary_action <context.args.get[3]>
            - if <[secondary_action]> == list:
                - define list_page <context.args.get[4]>
                - run List_Task_Script def:server|<[jail_name]>_wanteds|Wanted|<[list_page]>|true
                - stop
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
        - narrate "<yellow>#<red> ERROR: Syntax error. Follow the command syntax."

Command_Soldier:
    type: command
    debug: false
    name: soldiers
    description: Minecraft Soldiers (Jail) system.
    usage: /soldiers
    permission: soldier.jail.command
    tab complete:
        - choose <context.args.size>:
            - case 0:
                - determine <list[wanted|jailstick|sword]>
            - case 1:
                - if "!<context.raw_args.ends_with[ ]>":
                    - determine <list[wanted|jailstick|sword].filter[starts_with[<context.args.first>]]>
                - else:
                    - if <context.args.get[1]> == wanted:
                        - determine <list[add|list]>
            - case 2:
                - if "!<context.raw_args.ends_with[ ]>":
                    - if <context.args.get[1]> == wanted:
                        - determine <list[add|list]>
                - else:
                    - if <context.args.get[2]> == add:
                        - determine <server.online_players.parse[name]>
                    - if <context.args.get[2]> == list:
                        - determine 0
            - case 3:
                - if "!<context.raw_args.ends_with[ ]>":
                    - if <context.args.get[2]> == add:
                        - determine <server.online_players.parse[name]>
                    - if <context.args.get[2]> == list:
                        - determine 0
    script:
        - if !<player.has_flag[soldier_jail]>:
            - if !<server.has_flag[default_soldier_jail]>:
                - narrate "<red> ERROR: No default Jail set for soldiers"
                - narrate "<white> Please tell a Supreme Warden or an OP to set the default jail of the Soldiers or add you to a Jail"
                - stop
            - flag <player> soldier_jail:<server.flag[default_soldier_jail]>
            - flag server <server.flag[default_soldier_jail]>_soldiers:|:<player>
        - define action <context.args.get[1]>
        - if <[action]> == sword:
            - give guard_sword to:<player.inventory>
            - stop
        - if <[action]> == jailstick:
            - give jailstick to:<player.inventory>
            - stop
        - if <context.args.size> < 2:
            - goto syntax_error
        - define jail_name <player.flag[soldier_jail]>
        - if <[jail_name].ends_with[_spawn]>:
            - narrate "<red> ERROR: Invalid jail name. Please don't use _spawn in your jail name."
            - stop
        - if <cuboid[<[jail_name]>]||null> == null:
            - narrate "<red> ERROR: Jail <[jail_name].after[jail_]> doesn't exist."
            - stop
        - if <[action]> == wanted:
            - if <context.args.size> < 3:
                - goto syntax_error
            - define secondary_action <context.args.get[2]>
            - if <[secondary_action]> == list:
                - define list_page <context.args.get[3]>
                - run List_Task_Script def:server|<[jail_name]>_wanteds|Wanted|<[list_page]>
                - stop
            - if <[secondary_action]> == add:
                - define username <server.match_player[<context.args.get[3]>]||null>
                - if <[username]> == null:
                    - narrate "<red> ERROR: Invalid player username OR the player is offline."
                    - stop
                - if <server.has_flag[<[jail_name]>_wanteds]> && <server.flag[<[jail_name]>_wanteds].find[<[username]>]> != -1:
                    - narrate "<red> ERROR: The player is already a wanted of this jail"
                    - stop
                - flag server <[jail_name]>_wanteds:|:<[username]>
                - narrate "<blue> <[username].name> <green>added to the wanted list!"
                - stop
        - mark syntax_error
        - narrate "<yellow>#<red> ERROR: Syntax error. Follow the command syntax:"
        - narrate "<yellow>-<white> To add a wanted: /soldiers wanted add <yellow>username"
        - narrate "<yellow>-<white> To show a list of wanteds from a jail: /soldiers wanted list <yellow>number"
        - narrate "<yellow>-<white> To get a jailstick: /soldiers jailstick"
        - narrate "<yellow>-<white> To get a sword: /soldiers sword"

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

guard_sword:
    type: item
    debug: false
    material: iron_sword
    mechanisms:
        hides: enchants
    enchantments:
        - unbreaking:1
        - vanishing_curse
    display name: <blue>Guard Sword
    lore:
        - <gray>Only does damage to slaves.
        - <gray>Kill a slave to send them to
        - <gray>the max security jail.
        - <red>Lost on death

Soldier_Script:
    type: world
    debug: false
    events:
        on player right clicks player with:jailstick:
            - if !<player.is_op||<context.server>> && !<player.has_permission[soldier.jail.jailstick]>:
                    - narrate "<red>ERROR: What are you trying to do? You can't caught someone. <blue>Only SOLDIERS can!"
                    - stop
            - if !<script[Soldier_Script].cooled_down[<player>]>:
                - stop
            - if !<player.has_flag[soldier_jail]>:
                - if !<server.has_flag[default_soldier_jail]>:
                    - narrate "<red> ERROR: No default Jail set for soldiers"
                    - narrate "<white> Please tell a Supreme Warden or an OP to set the default jail of the Soldiers"
                    - stop
                - flag <player> soldier_jail:<server.flag[default_soldier_jail]>
                - flag server <server.flag[default_soldier_jail]>_soldiers:|:<player>
            - define jail <player.flag[soldier_jail]>
            - if <context.entity.in_group[slave]>:
                - if !<context.entity.has_flag[slave_timer]> || <context.entity.flag[owner]> != <[jail]>:
                    - narrate "<red> ERROR: This slave is property of someone!"
                    - stop
                - flag <context.entity> slave_timer:+:<script[Slaves_Config].data_key[slave_timer]>
                - narrate "<green> Slave: <red><context.entity.name> <green>time extended by <blue><script[Slaves_Config].data_key[slave_timer]> minutes"
                - narrate "<red> Your time got extended by <yellow><script[Slaves_Config].data_key[slave_timer]> minutes <red>SLAVE" targets:<context.entity>
                - cooldown 10s script:Soldier_Script
                - stop
            - if <context.entity.in_group[insurgent]> || <context.entity.in_group[civilian]> || <context.entity.in_group[default]> || <context.entity.in_group[vip]> || <context.entity.in_group[ultravip]> || <context.entity.in_group[supremevip]> || <context.entity.in_group[godvip]>:
                - if <server.has_flag[<[jail]>_wanteds]>:
                    - if <server.flag[<[jail]>_wanteds].find[<context.entity>]> == -1:
                        - flag server <[jail]>_wanteds:|:<context.entity>
                        - narrate "<red><context.entity.name> <green>was added to the <yellow>WANTED <green>list"
                    - else:
                        - narrate "<red><context.entity.name> <green>is already in the <yellow>WANTED <green>list"
                - else:
                    - flag server <[jail]>_wanteds:|:<context.entity>
                    - narrate "<red><context.entity.name> <green>was added to the <yellow>WANTED <green>list"
                - cooldown 10s script:Soldier_Script
        on player damages player with:guard_sword:
            - if <context.damager.has_flag[soldier_jail]>:
                - if <context.entity.in_group[slave]> && <context.entity.has_flag[slave_timer]>:
                    - stop
            - determine cancelled
        on player kills player:
            - if !<context.damager.has_permission[soldier.jail.wanted]>:
                - stop
            - if !<context.damager.has_flag[soldier_jail]>:
                - if <server.has_flag[default_soldier_jail]>:
                    - flag <context.damager> soldier_jail:<server.flag[default_soldier_jail]>
                - else:
                    - stop
            - if <context.entity.in_group[slave]>:
                - define killer_item <context.damager.inventory.slot[<context.damager.held_item_slot>]>
                - if <[killer_item].has_script> && <[killer_item].script.name.contains_all_text[guard_sword]>:
                    - if <context.entity.has_flag[slave_timer]>:
                        - if <context.entity.has_flag[non_max_jail]>:
                            - flag <context.entity> slave_max_timer:-:<script[Slaves_Config].data_key[slave_max_timer]>
                            - stop
                        - if <context.entity.has_flag[owner]>:
                            - execute as_server "slaves addmax <script[Soldiers_Config].data_key[max_security_jail]> <context.entity.name>" silent
                            - stop
                - stop
            - if !<context.damager.is_op> && !<context.damager.in_group[supremewarden]> && !<context.damager.in_group[soldier]> && !<context.damager.in_group[general]>:
                - stop
            - define jail <context.damager.flag[soldier_jail]>
            - define jail_slaves <[jail]>_slaves
            - define jail_wanted <[jail]>_wanteds
            - if <server.has_flag[<[jail_wanted]>]>:
                - if <server.flag[<[jail_wanted]>].find[<context.entity>]> != -1:
                    - flag server <[jail_wanted]>:<-:<context.entity>
                    - execute as_server "slaves add <context.damager.flag[soldier_jail].after[jail_]> <context.entity.name>" silent
                    - stop
            - if <context.entity.in_group[insurgent]>:
                - execute as_server "slaves add <context.damager.flag[soldier_jail].after[jail_]> <context.entity.name>" silent
                - stop
    # thanks to @mcmonkey for the idea
        on player drops jailstick:
            - remove <context.entity>
        on player drops guard_sword:
            - remove <context.entity>
        on player clicks in inventory with:jailstick:
            - inject locally abuse_prevention_click
        on player drags jailstick in inventory:
            - inject locally abuse_prevention_click
    abuse_prevention_click:
        - if <context.inventory.inventory_type> == player:
            - stop
        - if <context.inventory.inventory_type> == crafting:
            - if <context.raw_slot||<context.raw_slots.numerical.first>> >= 6:
                - stop
        - determine passively cancelled
        - inventory update