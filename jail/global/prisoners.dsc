# +----------------------
# |
# | S L A V E S
# |
# | Send prisoners to the jails.
# |
# +----------------------
#
# @author devnodachi
# @date 2020/08/02
# @denizen-build REL-1714
# @dependency devnodachi/jails
#
# Commands
# /prisoners spawn <jailname> - Sets the spawn point of the prisoner in the player position.
# /prisoners list <jailname> <#> - List the prisoners in this jail.
# /prisoners add <jailname> <username> - Adds a prisoners to a jail.
# /prisoners remove <jailname> <username> - Removes a prisoners from a Jail.
# /prisoners addmax <jailname> <username> - Adds a prisoners to this jail. (It's meant for the max security jail)
# /prisoners removemax <jailname> <username> - Removes a prisoners from this Jail. (It's meant for the max security jail)
# /prisoners time <jailname> info <username> - Checks the time in minutes of a prisoner.
# /prisoners time <jailname> add <username> <#> - Adds time in hours to a prisoner. (Each number is 1 hour)
# /prisoners time <jailname> remove <username> <#> - Remove time in hours to a prisoner. (Each number is 1 hour)
# /prisoners pickaxe - Replaces your hand with a prisoner pickaxe.
# Notables created here
# - jail_<name>_spawn [Used in Jails]

Command_Slaves:
    type: command
    debug: false
    name: prisoners
    description: Minecraft prisoner system.
    usage: /prisoners
    tab complete:
        - if !<player.is_op||<context.server>> && !<player.in_group[supremewarden]>:
            - stop
        - choose <context.args.size>:
            - case 0:
                - determine <list[spawn|list|add|addmax|remove|removemax|time|pickaxe]>
            - case 1:
                - if "!<context.raw_args.ends_with[ ]>":
                    - determine <list[spawn|list|add|addmax|remove|removemax|time|pickaxe].filter[starts_with[<context.args.first>]]>
                - else:
                    - if <server.has_flag[prison_jails]> && <context.args.get[1]> != pickaxe:
                        - determine <server.flag[prison_jails].parse[after[jail_]]>
            - case 2:
                - if <server.has_flag[prison_jails]>:
                    - if "!<context.raw_args.ends_with[ ]>":
                            - determine <server.flag[prison_jails].parse[after[jail_]]>
                    - else:
                        - if <context.args.get[1]> == list:
                            - determine <server.flag[prison_jails].size.div[10].truncate>
                        - if <context.args.get[1]> == time:
                            - determine <list[info|add|remove]>
                        - else:
                            - determine <server.online_players.parse[name]>
            - case 3:
                - if <server.has_flag[prison_jails]>:
                    - if "!<context.raw_args.ends_with[ ]>":
                        - if <context.args.get[1]> == list:
                            - determine <server.flag[prison_jails].size.div[10].truncate>
                        - if <context.args.get[1]> == time:
                            - determine <list[info|add|remove]>
                        - else:
                            - determine <server.online_players.parse[name]>
                    - else:
                        - if <context.args.get[3].contains_any_case_sensitive_text[add|remove]>:
                            - determine <server.online_players.parse[name]>
    script:
        - if !<player.is_op||<context.server>> && !<player.in_group[supremewarden]>:
            - narrate "<red>You do not have permission for that command."
            - stop
        - if <context.args.size> == 1 && <context.args.get[1]> == pickaxe:
            - give prisoner_pickaxe to:<player.inventory>
            - stop
        - if <context.args.size> < 2:
            - goto syntax_error
            - stop
        - define action <context.args.get[1]>
        - define name <context.args.get[2]>
        - define jail_name jail_<[name]>
        - if <cuboid[<[jail_name]>]||null> == null:
            - narrate "<red> Jail <[name]> doesn't exist."
            - stop
        - if <[action]> == time:
            - if <context.args.size> < 4:
                - narrate "<yellow>#<red> ERROR: Not enough arguments. Follow the command syntax."
                - stop
            - define secondary_action <context.args.get[3]>
            - define username <server.match_offline_player[<context.args.get[4]>]||null>
            - if <[username]> == null:
                - narrate "<red> ERROR: Invalid player username OR the player is offline."
                - stop
            - if !<[username].in_group[prisoner]> && !<[username].has_flag[prisoner_timer]>:
                - narrate "<red> ERROR: This player isn't a valid prisoner."
                - stop
            - if <[secondary_action]> == add || <[secondary_action]> == remove || <[secondary_action]> == info:
                - if <[secondary_action]> == info:
                    - narrate "<green> The remaining time of the prisoner <red><[username].name> <green>is <yellow><[username].flag[prisoner_timer]> <green>minutes"
                    - stop
                - if <context.args.size> < 5:
                    - narrate "<yellow>#<red> ERROR: Not enough arguments. Follow the command syntax."
                    - stop
                - define timer <context.args.get[5]>
                - if !<[timer].is_integer>:
                    - narrate "<red> ERROR: The time must be a integer number!"
                - if <[secondary_action]> == add:
                    - if <[username].flag[prisoner_timer].add[<[timer].mul[60]>]> < 0:
                        - narrate "<red> ERROR: The user can't have negative time!"
                        - stop
                    - flag <[username]> prisoner_timer:+:<[timer].mul[60]>
                    - narrate "<green> Added <blue><[timer]> hours to the prisoner <red><[username].name>"
                    - narrate "<green> The <yellow>jail <green>added <blue><[timer]> <green>hours to your time in jail" targets:<[username]>
                    - narrate "<green> Remaining time in Jail: <blue><[username].flag[prisoner_timer]> <green>minutes" targets:<[username]>
                    - stop
                - if <[secondary_action]> == remove:
                    - if <[username].flag[prisoner_timer].sub[<[timer].mul[60]>]> < 0:
                        - narrate "<red> ERROR: The user can't have negative time!"
                        - stop
                    - flag <[username]> prisoner_timer:-:<[timer].mul[60]>
                    - narrate "<green> Removed <red><[timer]> hours to the prisoner <red><[username].name>"
                    - narrate "<green> The <yellow>jail <green>removed <red><[timer]> <green>hours to your time in jail" targets:<[username]>
                    - narrate "<green> Remaining time in Jail: <blue><[username].flag[prisoner_timer]> <green>minutes" targets:<[username]>
                    - stop
        - if <[action]> == add:
            - if <context.args.size> < 3:
                - goto syntax_error
            - define username <server.match_offline_player[<context.args.get[3]>]||null>
            - if <[username]> == null:
                - narrate "<red> ERROR: Invalid player username OR the player is offline."
                - stop
            - define jail_prisoners <[jail_name]>_prisoners
            - define jail_spawn <[jail_name]>_spawn
            - if !<location[<[jail_spawn]>]||null> == null:
                - narrate "<red> ERROR: Please set the jail spawn with /prisoners spawn <yellow><[jail_name]> <red>while standing inside the jail"
                - stop
            - flag server <[jail_prisoners]>:|:<[username]>
            - flag <[username]> owner:<[jail_name]>
            - flag <[username]> prisoner_timer:<script[Slaves_Config].data_key[prisoner_timer]>
            - define record "Jail [<util.time_now.to_utc.format>]"
            - flag <[username]> criminal_record:|:<[record]>
            - if !<[username].groups.is_empty>:
                - flag <[username]> prisoner_groups:|:<[username].groups>
            - execute as_server "lp user <[username].name> parent set prisoner" silent
            - if <[username].is_online>:
                - teleport <[username]> <location[<[jail_spawn]>]>
                - narrate "<green> Welcome to the jail <red>PRISONER!" targets:<[username]>
            - if <[username].has_flag[marry]> && <[username].flag[marry].as_player.is_online> && <[username].flag[marry].as_player.has_flag[marry_jail]>:
                - flag <[username].flag[marry].as_player> marry_jail:!
                - execute as_server "prisoners add <[name]> <[username].flag[marry].as_player.name>" silent
                - narrate "<white> Your couple is in <red>JAIL <white>with you. Sweet <green>home<white>." targets:<[username]>|<[username].flag[marry].as_player>
            - narrate "<green> Prisoner <blue><[username].name> <green>added to the Jail!"
            - stop
        - if <[action]> == addmax || <[action]> == removemax:
            - define username <server.match_player[<context.args.get[3]>]||null>
            - if <[username]> == null:
                - narrate "<red> ERROR: Invalid player username OR the player is offline."
                - stop
            - if !<[username].in_group[prisoner]> && !<[username].has_flag[prisoner_timer]>:
                - narrate "<red> ERROR: This player isn't a valid prisoner."
                - stop
            - if <[action]> == addmax:
                - if <location[<[jail_name]>_spawn]||null> == null:
                    - narrate "<red> Jail <[name]> doesn't have a spawn set."
                    - stop
                - flag <[username]> non_max_jail:<[username].flag[owner]>
                - flag <[username]> owner:<[jail_name]>
                - teleport <[username]> <location[<[username].flag[owner]>_spawn]>
                - narrate "<red> <[username].name> <green>was added to the max security Jail."
                - stop
            - if <[action]> == removemax:
                - if !<[username].has_flag[non_max_jail]>:
                    - narrate "<red> ERROR: This player is not in a high security Jail."
                    - stop
                - flag <[username]> prisoner_max_timer:!
                - flag <[username]> owner:<[username].flag[non_max_jail]>
                - flag <[username]> non_max_jail:!
                - teleport <[username]> <location[<[username].flag[owner]>_spawn]>
                - narrate "<red> <[username].name> <green>was removed from the max security Jail."
                - stop
        - if <[action]> == spawn:
            - if !<cuboid[<[jail_name]>].contains_location[<player.location>]>:
                - narrate "<red> ERROR: Stand on the jail boundary to set the prisoner spawn."
                - stop
            - note <player.location> as:<[jail_name]>_spawn
            - narrate "<green> Prisoner spawn set for the jail <[name]>."
            - stop
        - if <[action]> == list && <context.args.size> == 3:
            - define list_page <context.args.get[3]>
            - run List_Task_Script def:server|<[jail_name]>_prisoners|Prisoner|<[list_page]>|true|Jail
            - stop
        - if <[action]> == remove && <context.args.size> == 3:
            - define username <server.match_offline_player[<context.args.get[3]>]||null>
            - if <[username]> == null:
                - narrate "<red> ERROR: Invalid player username OR the player is offline."
                - stop
            - if !<[username].in_group[prisoner]>:
                - narrate "<red> ERROR: This player isn't a prisoner."
                - stop
            - define jail_prisoners <[jail_name]>_prisoners
            - flag server <[jail_prisoners]>:<-:<[username]>
            - flag <[username]> owner:!
            - flag <[username]> prisoner_timer:!
            - flag <[username]> non_max_jail:!
            - flag <[username]> prisoner_max_timer:!
            - if <[username].has_flag[prisoner_groups]>:
                - foreach <[username].flag[prisoner_groups]> as:group:
                    - execute as_server "lp user <[username].name> parent add <[group]>" silent
            - flag <[username]> prisoner_groups:!
            - execute as_server "lp user <[username].name> parent remove prisoner" silent
            - narrate "<green> Prisoner <blue><[username].name> <green>removed!"
            - stop
        - mark syntax_error
        - narrate "<yellow>#<red> ERROR: Syntax error. Follow the command syntax."

Slave_Script:
    type: world
    debug: false
    events:
        after player respawns:
            - if <player.in_group[prisoner]> && <player.has_flag[owner]>:
                - if <player.has_flag[prisoner_timer]>:
                    - if <server.has_flag[court_active]>:
                        - if <server.flag[court_prisoner].contains_all_case_sensitive_text[<player.uuid>]>:
                            - stop
                    - define owner_name_spawn <player.flag[owner]>_spawn
                    - teleport <player> <location[<[owner_name_spawn]>]>
                    - narrate "<red> You died but you're a prisoner. Now you're with your owner."
                - else:
                    - define owner <server.match_player[<player.flag[owner]>]||null>
                    - if <[owner]> != null:
                        - teleport <player> <[owner].location>
                        - narrate "<red> You died but you're a prisoner. Now you're with your owner."
        on system time minutely:
            - foreach <server.online_players> as:server_player:
                - if <[server_player].in_group[prisoner]> && <[server_player].has_flag[prisoner_timer]>:
                    - if <[server_player].has_flag[owner]>:
                        - if <server.has_flag[court_active]>:
                            - if <server.flag[court_prisoner].contains_all_case_sensitive_text[<[server_player].uuid>]>:
                                - foreach next
                        - define owner <[server_player].flag[owner]>
                        - flag <[server_player]> prisoner_timer:-:1
                        - if <[server_player].flag[prisoner_timer]> <= 0.0:
                            - execute as_server "prisoners remove <[owner].after[jail_]> <[server_player].name>" silent
                            - narrate "<green> You are free <red>PRISONER" targets:<[server_player]>
                            - stop
                    - if <[server_player].has_flag[non_max_jail]>:
                        - flag <[server_player]> prisoner_max_timer:+:1
                        - if <[server_player].flag[prisoner_max_timer]> >= <script[Slaves_Config].data_key[prisoner_max_timer]>:
                            - flag <[server_player]> prisoner_max_timer:!
                            - flag <[server_player]> owner:<[server_player].flag[non_max_jail]>
                            - flag <[server_player]> non_max_jail:!
                            - teleport <[server_player]> <location[<[server_player].flag[owner]>_spawn]>
                            - narrate "<green> You are free <red>PRISONER <green>of the max security jail" targets:<[server_player]>
                        - else:
                            - define time_remaining <script[Slaves_Config].data_key[prisoner_max_timer].sub[<[server_player].flag[prisoner_max_timer]>]>
                            - actionbar "<red> PRISONER: <green>Your time remaining in the max security jail is: <yellow><[time_remaining]> minutes" targets:<[server_player]>
        on command:
            - if <context.source_type> == PLAYER:
                - if <player.in_group[prisoner]> && <player.has_flag[prisoner_timer]>:
                    - if <context.command> == tpa:
                        - determine FULFILLED
                    - if <context.args.size> < 1:
                        - stop
                    - if <context.command> == t || <context.command> == town:
                        - if <context.args.get[1]> == spawn:
                            - determine FULFILLED

prisoner_pickaxe:
    type: item
    debug: false
    material: iron_pickaxe
    mechanisms:
        repair_cost: 99
        hides: attributes|enchants
        enchantments: unbreaking,3
    display name: <red>Prisoner Pickaxe
    lore:
        - <gray>Mine with this
        - <gray>pickaxe... <red>PRISONER!
        - <gray>Your resources are
        - <gray>the jail resources.