# +----------------------
# |
# | S L A V E S
# |
# | Send slaves to the jails.
# |
# +----------------------
#
# @author devnodachi
# @date 2020/08/02
# @denizen-build REL-1714
# @dependency devnodachi/jails
#
# Commands
# /slaves spawn <jailname> - Sets the spawn point of the slave in the player position.
# /slaves list <jailname> <#> - List the slaves in this jail.
# /slaves add <jailname> <username> - Adds a slaves to a jail.
# /slaves remove <jailname> <username> - Removes a slaves from a Jail.
# /slaves addmax <jailname> <username> - Adds a slaves to this jail. (It's meant for the max security jail)
# /slaves removemax <jailname> <username> - Removes a slaves from this Jail. (It's meant for the max security jail)
# /slaves time <jailname> info <username> - Checks the time in minutes of a slave.
# /slaves time <jailname> add <username> <#> - Adds time in hours to a slave. (Each number is 1 hour)
# /slaves time <jailname> remove <username> <#> - Remove time in hours to a slave. (Each number is 1 hour)
# /slaves pickaxe - Replaces your hand with a slave pickaxe.
# Notables created here
# - jail_<name>_spawn [Used in Jails]

Command_Slaves:
    type: command
    debug: false
    name: slaves
    description: Minecraft slave system.
    usage: /slaves
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
            - give slave_pickaxe to:<player.inventory>
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
                - narrate "<yellow>#<red> ERROR: Not enough arguments. Follow the command syntax:"
                - narrate "<yellow>-<red> To check time of a slave in a jail: <white>/slaves time <yellow><[jail_name]> <white>info <yellow>username"
                - narrate "<yellow>-<red> To add time (1 hour per each number) to a slave in a jail: <white>/slaves time <yellow><[jail_name]> <white>add <yellow>username <yellow>number"
                - narrate "<yellow>-<red> To remove time (1 hour per each number) to a slave in a jail: <white>/slaves time <yellow><[jail_name]> <white>remove <yellow>username <yellow>number"
                - stop
            - define secondary_action <context.args.get[3]>
            - define username <server.match_player[<context.args.get[4]>]||null>
            - if <[username]> == null:
                - narrate "<red> ERROR: Invalid player username OR the player is offline."
                - stop
            - if !<[username].in_group[slave]> && !<[username].has_flag[slave_timer]>:
                - narrate "<red> ERROR: This player isn't a valid slave."
                - stop
            - if <[secondary_action]> == add || <[secondary_action]> == remove || <[secondary_action]> == info:
                - if <[secondary_action]> == info:
                    - narrate "<green> The remaining time of the slave <red><[username].name> <green>is <yellow><[username].flag[slave_timer]> <green>minutes"
                    - stop
                - if <context.args.size> < 5:
                    - narrate "<yellow>#<red> ERROR: Not enough arguments. Follow the command syntax:"
                    - narrate "<yellow>-<red> To add time (1 hour per each number) to a slave in a jail: <white>/slaves time <yellow><[jail_name]> <white>add <yellow><[username]> <yellow>number"
                    - narrate "<yellow>-<red> To remove time (1 hour per each number) to a slave in a jail: <white>/slaves time <yellow><[jail_name]> <white>remove <yellow><[username]> <yellow>number"
                    - stop
                - define timer <context.args.get[5]>
                - if !<[timer].is_integer>:
                    - narrate "<red> ERROR: The time must be a integer number!"
                - if <[secondary_action]> == add:
                    - if <[username].flag[slave_timer].add[<[timer].mul[60]>]> < 0:
                        - narrate "<red> ERROR: The user can't have negative time!"
                        - stop
                    - flag <[username]> slave_timer:+:<[timer].mul[60]>
                    - narrate "<green> Added <blue><[timer]> hours to the slave <red><[username].name>"
                    - narrate "<green> The <yellow>jail <green>added <blue><[timer]> <green>hours to your time in jail" targets:<[username]>
                    - narrate "<green> Remaining time in Jail: <blue><[username].flag[slave_timer]> <green>minutes" targets:<[username]>
                    - stop
                - if <[secondary_action]> == remove:
                    - if <[username].flag[slave_timer].sub[<[timer].mul[60]>]> < 0:
                        - narrate "<red> ERROR: The user can't have negative time!"
                        - stop
                    - flag <[username]> slave_timer:-:<[timer].mul[60]>
                    - narrate "<green> Removed <red><[timer]> hours to the slave <red><[username].name>"
                    - narrate "<green> The <yellow>jail <green>removed <red><[timer]> <green>hours to your time in jail" targets:<[username]>
                    - narrate "<green> Remaining time in Jail: <blue><[username].flag[slave_timer]> <green>minutes" targets:<[username]>
                    - stop
        - if <[action]> == add:
            - if <context.args.size> < 3:
                - goto syntax_error
            - define username <server.match_player[<context.args.get[3]>]||null>
            - if <[username]> == null:
                - narrate "<red> ERROR: Invalid player username OR the player is offline."
                - stop
            - define jail_slaves <[jail_name]>_slaves
            - define jail_spawn <[jail_name]>_spawn
            - if !<location[<[jail_spawn]>]||null> == null:
                - narrate "<red> ERROR: Please set the jail spawn with /slaves spawn <yellow><[jail_name]> <red>while standing inside the jail"
                - stop
            - flag server <[jail_slaves]>:|:<[username]>
            - flag <[username]> owner:<[jail_name]>
            - flag <[username]> slave_timer:<script[Slaves_Config].data_key[slave_timer]>
            - flag <[username]> jail_owner:!
            - flag <[username]> owner_block_limit:!
            - if !<[username].groups.is_empty>:
                - flag <[username]> slave_groups:|:<[username].groups>
            - execute as_server "lp user <[username].name> parent set slave" silent
            - if <[username].is_online>:
                - if !<context.server>:
                    - teleport <[username]> <location[<[jail_spawn]>]>
                - narrate "<green> Welcome to the jail <red>SLAVE!" targets:<[username]>
            - narrate "<green> Slave <blue><[username].name> <green>added to the Jail!"
            - stop
        - if <[action]> == addmax || <[action]> == removemax:
            - define username <server.match_player[<context.args.get[3]>]||null>
            - if <[username]> == null:
                - narrate "<red> ERROR: Invalid player username OR the player is offline."
                - stop
            - if !<[username].in_group[slave]> && !<[username].has_flag[slave_timer]>:
                - narrate "<red> ERROR: This player isn't a valid slave."
                - stop
            - if <[action]> == addmax:
                - if <location[<[jail_name]>_spawn]||null> == null:
                    - narrate "<red> Jail <[name]> doesn't have a spawn set."
                    - stop
                - if <[username].has_flag[jail_owner]>:
                    - flag <[username]> non_max_jail:<[username].flag[jail_owner]>
                    - flag <[username]> jail_owner:!
                    - flag <[username]> owner:<[jail_name]>
                - else:
                    - flag <[username]> non_max_jail:<[username].flag[owner]>
                    - flag <[username]> owner:<[jail_name]>
                - teleport <[username]> <location[<[username].flag[owner]>_spawn]>
                - narrate "<red> <[username].name> <green>was added to the max security Jail."
                - stop
            - if <[action]> == removemax:
                - if !<[username].has_flag[non_max_jail]>:
                    - narrate "<red> ERROR: This player is not in a high security Jail."
                    - stop
                - flag <[username]> slave_max_timer:!
                - flag <[username]> owner:<[username].flag[non_max_jail]>
                - flag <[username]> non_max_jail:!
                - teleport <[username]> <location[<[username].flag[owner]>_spawn]>
                - narrate "<red> <[username].name> <green>was removed from the max security Jail."
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
            - run List_Task_Script def:<[jail_name]>_slaves|Slave|<[list_page]>|true
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
            - flag <[username]> slave_lead_queue:!
            - flag <[username]> non_max_jail:!
            - flag <[username]> slave_max_timer:!
            - if <[username].has_flag[slave_groups]>:
                - foreach <[username].flag[slave_groups]> as:group:
                    - execute as_server "lp user <[username].name> parent add <[group]>" silent
            - flag <[username]> slave_groups:!
            - execute as_server "lp user <[username].name> parent remove slave" silent
            - narrate "<green> Slave <blue><[username].name> <green>removed!"
            - stop
        - mark syntax_error
        - narrate "<yellow>#<red> ERROR: Syntax error. Follow the command syntax:"
        - narrate "<yellow>-<red> To set the spawn of a jail: <white>/slaves spawn <yellow>jailname"
        - narrate "<yellow>-<red> To add a slave to a jail: <white>/slaves add <yellow>jailname <yellow>username"
        - narrate "<yellow>-<red> To remove a slave from a jail: <white>/slaves remove <yellow>jailname <yellow>username"
        - narrate "<yellow>-<red> To show a list of slaves from a jail: <white>/slaves list <yellow>jailname <yellow>number"
        - narrate "<yellow>-<red> To check time of a slave in a jail: <white>/slaves time <yellow>jailname <white>info <yellow>username"
        - narrate "<yellow>-<red> To add time (1 hour per each number) to a slave in a jail: <white>/slaves time <yellow>jailname <white>add <yellow>username <yellow>number"
        - narrate "<yellow>-<red> To remove time (1 hour per each number) to a slave in a jail: <white>/slaves time <yellow>jailname <white>remove <yellow>username <yellow>number"
        - narrate "<yellow>-<red> To get a slave pickaxe <white>/slaves pickaxe"

Slave_Script:
    type: world
    debug: false
    events:
        after player respawns:
            - if <player.in_group[slave]> && <player.has_flag[owner]>:
                - if <player.has_flag[slave_timer]> && !<player.has_flag[jail_owner]>:
                    - if <server.has_flag[court_active]>:
                        - if <server.flag[court_slave].contains_all_case_sensitive_text[<player.uuid>]>:
                            - stop
                    - define owner_name_spawn <player.flag[owner]>_spawn
                    - teleport <player> <location[<[owner_name_spawn]>]>
                    - narrate "<red> You died but you're a slave. Now you're with your owner."
                - if <player.has_flag[jail_owner]>:
                    - define owner <server.match_player[<player.flag[owner]>]||null>
                    - if <[owner]> != null:
                        - teleport <player> <[owner].location>
                        - narrate "<red> You died but you're a slave. Now you're with your owner."
                - if !<player.has_flag[slave_timer]> && !<player.has_flag[jail_owner]>:
                    - define owner <server.match_player[<player.flag[owner]>]||null>
                    - if <[owner]> != null:
                        - teleport <player> <[owner].location>
                        - narrate "<red> You died but you're a slave. Now you're with your owner."
        on system time minutely:
            - foreach <server.online_players> as:server_player:
                - if <[server_player].in_group[slave]> && <[server_player].has_flag[slave_timer]>:
                    - if <[server_player].has_flag[owner]>:
                        - if <server.has_flag[court_active]>:
                            - if <server.flag[court_slave].contains_all_case_sensitive_text[<[server_player].uuid>]>:
                                - foreach next
                        - define owner <[server_player].flag[owner]>
                        - flag <[server_player]> slave_timer:-:1
                        - if <[server_player].flag[slave_timer]> <= 0.0:
                            - execute as_server "slaves remove <[owner].after[jail_]> <[server_player].name>" silent
                            - narrate "<green> You are free <red>SLAVE" targets:<[server_player]>
                            - stop
                    - if <[server_player].has_flag[non_max_jail]>:
                        - flag <[server_player]> slave_max_timer:+:1
                        - if <[server_player].flag[slave_max_timer]> >= <script[Slaves_Config].data_key[slave_max_timer]>:
                            - flag <[server_player]> slave_max_timer:!
                            - flag <[server_player]> owner:<[server_player].flag[non_max_jail]>
                            - flag <[server_player]> non_max_jail:!
                            - teleport <[server_player]> <location[<[server_player].flag[owner]>_spawn]>
                            - narrate "<green> You are free <red>SLAVE <green>of the max security jail" targets:<[server_player]>
                        - else:
                            - define time_remaining <script[Slaves_Config].data_key[slave_max_timer].sub[<[server_player].flag[slave_max_timer]>]>
                            - actionbar "<red> SLAVE: <green>Your time remaining in the max security jail is: <yellow><[time_remaining]> minutes" targets:<[server_player]>
        on command:
            - if <context.source_type> == PLAYER:
                - if <player.in_group[slave]> && <player.has_flag[slave_timer]>:
                    - if <context.command> == tpa:
                        - determine FULFILLED
                    - if <context.args.size> < 1:
                        - stop
                    - if <context.command> == t || <context.command> == town:
                        - if <context.args.get[1]> == spawn:
                            - determine FULFILLED

slave_pickaxe:
    type: item
    debug: false
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